# EXAMPLE - a finished project doc in the target register

This file is docflow's worked example, not documentation of docflow itself. It shows
the register `/docflow:spec` writes a spec's `Documentation` section in, and the bar
`/docflow:accept` holds placements to. The project it describes - webhook delivery -
is fictional; the shape is the point. A project's own docs-style skill or existing
docs override this example; it calibrates when they are silent.

What it encodes:

1. **Business, UI, and behaviour lead - about 3/5 of the doc.** When a doc grows, it
   grows here, not in the technical part.
2. **Technical means engineering reasoning - about 2/5.** What the chosen algorithm
   or data structure buys, its efficiency, which alternatives lost and why. Never
   code walkthroughs.
3. **Implementation identifiers are sparse and selective.** Config file paths and
   their important keys, directories of important content, public contract keys -
   yes. Variable and class names, internal columns, internal module paths - rarely
   or never; those live in comments next to the code.

---

# Webhook delivery — outbound notifications

How the app tells a customer's own systems that something happened, without
them polling for it. This is the **delivery feature** — which events exist and
what their payloads mean is [events.md](./events.md); the settings screens are
[settings-integrations.md](./settings-integrations.md). Inbound webhooks (the
app receiving calls from third parties) are a different feature and not covered
here.

## Why webhooks

- Customers build on the app: when an invoice is paid or a subscription
  cancels, *their* systems — ERP, provisioning, a Slack channel — need to know
  right away.
- Without push, every integrator writes the same polling cron: wasteful, slow,
  rate-limit-bound, and each one slightly wrong. Webhooks replace all of that
  with one mechanism the app owns.
- Success looks like: a customer wires up an endpoint in minutes, watches the
  first delivery arrive in the log, and trusts the channel enough to hang
  billing-critical automation on it. Trust is the product here — the rest of
  this doc is mostly about earning it.

## What the customer experiences

- **Registering** — in Settings → Integrations the customer adds an HTTPS URL,
  picks which event types it should receive (the filter), and gets a signing
  secret to verify our calls with. One customer can run many endpoints — a
  test one and a production one is the normal pattern.
- **Trying it out** — a "send test event" button fires a synthetic event at
  the endpoint, so the customer proves their receiver works before any real
  traffic depends on it. The test delivery appears in the log like any other.
- **The delivery log** — every endpoint has a log of its deliveries: event,
  status, response, and timing. A failing delivery shows the receiver's
  error verbatim — the customer debugs their side from our log, without a
  support ticket. The log is the feature's face: when a customer asks "did
  you tell us?", the answer is always one page away.
- **Redeliver** — any delivery can be re-sent by hand from the log. This is
  the recovery path after the customer's system was down, and support's first
  tool. It is deliberately manual: the customer decides what their now-healthy
  system gets again.
- **Endpoint states** — an endpoint is active or disabled. A receiver
  answering `410 Gone` disables it immediately (that response means "this URL
  is dead, stop calling"). An endpoint failing every delivery for 7 days is
  auto-disabled and its owner emailed — silent decay is worse than a hard
  stop, because the customer finds out from us, not from a month of missing
  data. @TODO (not built)
- **A dead endpoint hurts only itself** — deliveries to other endpoints, and
  other customers, are never delayed by one receiver being down.

## What a receiver must handle

The contract in behavioural terms — this is what the integration docs promise,
and what the customer's developer builds against:

- **Duplicates can happen.** A delivery may arrive twice (a retry after a
  crash mid-send). Every delivery carries a stable delivery id; receivers
  deduplicate on it.
- **Order is not guaranteed.** A retried old event can land after a newer one.
  A receiver that needs sequence sorts by the payload's `occurred_at` — the
  moment it happened, not when it arrived.
- **Acknowledge fast.** Any success response settles the delivery; anything
  else gets retried. Receivers should accept, store, and process later — not
  process inline while we wait.

These two allowances (duplicates, disorder) are what make the guarantee
honest: exactly-once ordered delivery over plain HTTP is a promise nobody can
keep, and pretending to would let one stuck delivery block everything behind
it. We promise at-least-once, unordered — and keep it.

## The model

- **Event** — something that happened; immutable, already persisted
  ([events.md](./events.md)).
- **Endpoint** — a registered URL, its signing secret, and its event-type
  filter.
- **Delivery** — one (event, endpoint) pair: the unit that is queued,
  attempted, retried, and settled.

An event fans out to one delivery per matching endpoint the moment it is
published; from then on each delivery lives and dies alone.

## The queue

- The queue is a table in the main database — one delivery, one row, carrying
  where the delivery stands, how many attempts it has had, when the next is
  due, and the last error the log shows. There is no message broker.
- A table won over a broker because it makes the hard things free: the queue
  survives restarts because it *is* the database, the delivery log is a plain
  query over it, and delivery state is transactional with the rest of the
  app's data. A broker would buy throughput and fan-out that webhook volume
  never approaches, at the price of running and monitoring a second stateful
  system.
- Dispatch is claim-by-row-lock: any number of dispatcher processes poll for
  due deliveries and the database itself arbitrates who gets which row. Scaling
  out is just starting more processes — no leader, no coordinator, no rebalancing.

## Retries and the request

- Backoff is exponential with full jitter: each wait is drawn at random, up to
  a ceiling that doubles from about half a minute to a one-hour cap. Jitter is
  the point, not a refinement — when an endpoint comes back from an outage,
  its backlog must trickle in, not stampede in one synchronized wave.
- Ten attempts spread over roughly six hours, then the delivery fails for
  good; past that, recovery is the redeliver button, not a longer tail. Both
  knobs are configuration, not code — `max_attempts` and `delivery_timeout`
  (10 s) in the `[webhooks]` block of `config/app.toml`.
- Each attempt is one signed JSON `POST`: the event type, the delivery id, the
  event's timestamp, and the payload ([events.md](./events.md) owns the
  schemas). The signature is an HMAC over the delivery id, an
  attempt timestamp, and the body — one verification gives the receiver
  integrity and freshness together, and stale replays die with it. The scheme
  is versioned so a future one can ship alongside during a migration window.
- Secret rotation — two active secrets per endpoint, signatures sent for both
  until the old one retires. @TODO (not built)

## Out of scope

- Event types and payload schemas → [events.md](./events.md).
- The settings screens (register, filter, redeliver, delivery log) →
  [settings-integrations.md](./settings-integrations.md).
- Inbound webhooks — a separate feature, separately specced.
