# Flight Management Module – Feature Document

## Executive Summary
The Flight Management Module is the core user-facing capability of the India Airport Passenger Experience Platform. It delivers real-time flight data, live tracking, smart notifications, and operational views to passengers and airport staff through a responsive React PWA. The design follows the Ocean Professional theme, providing a clean, modern aesthetic with accessible components and smooth interactions. The module integrates with flight data APIs and WebSocket streams, supports role-based experiences, and includes analytics, observability, and privacy by design. This document defines scope, personas, user journeys, feature sets, UX guidelines, integrations, environment variables, notifications, security, rollout strategy, and acceptance criteria to enable coordinated delivery by Product, Design, and Engineering.

## Goals and Non-Goals
### Goals
- Provide accurate, real-time flight information (status, gate, terminal, delays) with live updates via WebSockets.
- Offer live tracking and predictive insights (ETA adjustments, gate changes) for passengers.
- Deliver staff operational dashboards for monitoring inbound/outbound flights, congestion, and alerts.
- Enable smart, preference-based notifications across in-app and push channels.
- Ensure responsive PWA performance with offline-tolerant states and graceful fallbacks.
- Align UI with Ocean Professional theme and ensure WCAG 2.1 AA accessibility.
- Instrument analytics and telemetry for usage, performance, and reliability KPIs.

### Non-Goals
- Building flight data provider infrastructure (use external APIs/backends).
- Implementing payment or commercial upsell flows beyond basic promotion placeholders.
- Deep airline CRM features beyond contextual links.
- Managing airport-wide IoT integrations (beyond consuming published data).

## Personas and Key Use Cases
### Personas
- Passenger Priya: Domestic traveler using mobile PWA to check flight status, receive alerts, and navigate gates.
- Frequent Flyer Farhan: Power user enabling granular notifications and historical status trends.
- Operations Officer Om: Airport staff monitoring flight operations, congestion, and alerts on tablets/desktops.
- Gate Agent Gauri: Staff managing gate changes and passenger communications.

### Key Use Cases
- Passenger checks live flight status, subscribes to notifications, and receives gate change alerts.
- Passenger views live aircraft progress (map view placeholder) and terminal wayfinding links.
- Staff monitors flight queues, delay clusters, and receives operational alerts (e.g., weather impact).
- Staff resolves alerts and posts status notes visible to staff users.

## User Stories and Acceptance Criteria
### Passenger
1) As a passenger, I can search for my flight by number or route and see real-time status.
- Acceptance:
  - Search returns matching flights within 1 second on average.
  - Result shows airline, flight number, origin/destination, scheduled/estimated times, terminal/gate, and status.
  - Live updates reflect within ≤5s of backend change (WebSocket) or ≤30s fallback (polling).

2) As a passenger, I can “follow” a flight to receive notifications.
- Acceptance:
  - Subscribe/unsubscribe works instantly with visual confirmation.
  - Notification preferences (push/in-app) are saved per user/device.
  - Users can view a notification history feed.

3) As a passenger, I can view a live tracking view and predicted arrival time.
- Acceptance:
  - Map placeholder or status timeline renders with position/phase indicators; when map unavailable, show timeline-based fallback.
  - ETA predictions update with stream messages.

### Staff
4) As a staff user, I can view an operational dashboard with inbound/outbound lists and filters.
- Acceptance:
  - Table or card list is filterable by airline, status, terminal, time window.
  - Aggregate widgets show counts by status and trend spark-lines.

5) As a staff user, I can acknowledge and resolve operational alerts.
- Acceptance:
  - Alerts list supports “acknowledge” and “resolve” with audit timestamps.
  - Alert status updates propagate to other staff clients via WebSocket.

6) As a staff user, I can annotate a flight (internal note).
- Acceptance:
  - Notes visible only to staff; persisted via backend; edits tracked with user/time.

## Feature Set (Passenger vs Staff)
### Passenger Features
- Flight search (flight number, route, date).
- Flight detail page with real-time status, terminal/gate, baggage belt, delay reason if provided.
- Live tracking/timeline with ETA prediction.
- Follow/subscribe to notifications; notification center.
- Save frequent flights and airlines.
- Wayfinding links (deeplinks/placeholders to maps).
- Accessibility options (text size, contrast toggle).
- Offline support states (cached searches, last-known status).

### Staff Features
- Operational dashboard: inbound/outbound boards, filters, and KPIs.
- Alerts center: auto-generated alerts (delay clusters, weather, gate conflicts).
- Acknowledge/resolve alerts with audit trail.
- Flight annotations (staff-only notes).
- Role-based views for gate agents vs operations officers.
- Bulk actions (e.g., filter acknowledgement).

## Information Architecture and Navigation
- Entry: Bottom tab navigation (PWA mobile):
  - Flights (default): Search and Saved flights
  - Chatbot: AI assistant
  - Notifications: Center/history
  - Dashboards: Staff-only; hidden until authenticated and authorized
- Passenger Flow:
  - Flights tab → Search → Results → Flight Detail → Follow/Unfollow → Notification Center
  - Saved Flights accessible from Flights tab
- Staff Flow:
  - Login → Dashboards tab → Boards (Inbound/Outbound) → Alerts → Flight Detail → Notes/Actions
- Cross-cutting:
  - App header with role indicator; overflow menu for preferences and accessibility settings.

## UI/UX Overview and Components (aligned to Ocean Professional)
Theme tokens (Ocean Professional):
- Primary #2563EB, Secondary/Success #F59E0B, Error #EF4444
- Background #f9fafb, Surface #ffffff, Text #111827
- Gradient: from-blue-500/10 to-gray-50
Design guidelines:
- Modern, minimalist surfaces with subtle shadows and rounded corners (8–12px radius).
- Smooth transitions on hover/press; large touch targets; reduced motion preference honored.
- High-contrast mode and dark mode paths via CSS variables.

Suggested React components:
- Global
  - ThemeProvider: handles Ocean Professional tokens; dark/light toggle using data-theme attributes (extend current App.css pattern).
  - AppShell: Header, BottomTabs, RoleGuard.
- Passenger
  - FlightSearchBar
  - FlightResultList (virtualized list if needed)
  - FlightCard
  - FlightDetail (StatusHeader, Timeline, InfoChips, GateBadge, BaggageInfo)
  - FollowButton (subscription state)
  - NotificationCenter (NotificationItem)
  - SavedFlightsList
- Staff
  - OpsDashboard (StatsWidgets, TrendSparkline, Filters)
  - FlightBoard (InboundBoard, OutboundBoard)
  - AlertsPanel (AlertItem with acknowledge/resolve)
  - StaffNotesPanel
- Shared
  - Modal, Drawer, Toast
  - EmptyState, ErrorState, SkeletonLoader
  - PaginationControls, FilterChips

Motion and feedback:
- Loading skeletons for data fetch.
- Toasts for subscription changes and errors.
- Reduced motion option to disable complex transitions.

## Real-time Data & Integrations (APIs, WebSockets)
Data sources:
- REST: Flight search, flight detail, saved flights, staff notes, alerts.
- WebSocket: Flight status updates, alert updates, dashboard metrics.
- Push service: Browser push for web PWA.

API patterns (example endpoints; adapt to actual backend):
- GET {REACT_APP_API_BASE}/flights?query=…&date=…
- GET {REACT_APP_API_BASE}/flights/{id}
- POST {REACT_APP_API_BASE}/subscriptions (body: {flightId, channel})
- GET {REACT_APP_API_BASE}/notifications
- GET {REACT_APP_API_BASE}/dashboards/ops?window=…
- GET {REACT_APP_API_BASE}/alerts
- POST {REACT_APP_API_BASE}/alerts/{id}/ack
- POST {REACT_APP_API_BASE}/alerts/{id}/resolve
- POST {REACT_APP_API_BASE}/flights/{id}/notes

WebSocket channels:
- {REACT_APP_WS_URL}/ws?token=…
  - topics: flight_updates, alert_updates, ops_metrics
  - message contract: {type, flightId, status, eta, gate, timestamp}

Polling fallback:
- If WS unavailable, poll critical views every 30s; exponential backoff on failure.

## Environment Variables Mapping
Use these variables in the React PWA build/runtime:
- REACT_APP_API_BASE: Base URL for REST APIs (passenger and staff).
- REACT_APP_BACKEND_URL: Canonical backend origin (CORS, deep links).
- REACT_APP_FRONTEND_URL: Public frontend origin (push permissions and redirects).
- REACT_APP_WS_URL: WebSocket base URL for real-time updates.
- REACT_APP_NODE_ENV: build/runtime environment hint (development/production).
- REACT_APP_NEXT_TELEMETRY_DISABLED: disable framework telemetry if proxied; default true.
- REACT_APP_ENABLE_SOURCE_MAPS: control source map generation.
- REACT_APP_PORT: local dev server port (default 3000).
- REACT_APP_TRUST_PROXY: if behind reverse proxy in deployments.
- REACT_APP_LOG_LEVEL: info|warn|error for client logger.
- REACT_APP_HEALTHCHECK_PATH: route to expose health status (e.g., /healthz).
- REACT_APP_FEATURE_FLAGS: JSON/CSV feature flags (e.g., {“opsDashboards”:true}).
- REACT_APP_EXPERIMENTS_ENABLED: enable experiments/rollouts.

Frontend usage examples (pseudo-code):
```javascript
const API_BASE = process.env.REACT_APP_API_BASE;
const WS_URL = process.env.REACT_APP_WS_URL;
const FLAGS = JSON.parse(process.env.REACT_APP_FEATURE_FLAGS || "{}");
```

## Notifications Strategy (in-app, push, email/SMS placeholders)
- In-app:
  - Real-time toasts and NotificationCenter list.
  - Badge counts on tab.
- Push (browser):
  - Request permission on follow action, not on app load.
  - Topic-based or per-flight subscriptions; handle token rotation.
- Email/SMS:
  - Placeholder hooks to be configured server-side; show contact verification UI when enabled.
- Quiet hours:
  - Local preference to limit night-time alerts; critical alerts bypass by choice.
- Delivery reliability:
  - If WebSocket disconnected, queue local notifications from polling deltas.

## Analytics, Observability, and Telemetry
Metrics:
- Feature usage: searches per session, follows per user, dashboard active time.
- Performance: TTFB, FCP, LCP, CLS, TBT, P95 page/API times.
- Reliability: WS connection uptime, reconnection attempts, API error rate.
- Notification funnel: opt-in rate, delivery, open/click through.

Instrumentation:
- Client events via a lightweight analytics SDK or custom endpoint at {REACT_APP_BACKEND_URL}/analytics.
- Console logs respect REACT_APP_LOG_LEVEL and are sampled in production.
- Health route at REACT_APP_HEALTHCHECK_PATH returns OK when core services reachable.

Dashboards:
- Frontend emits page view and component mount events; backend aggregates.

## Accessibility and Performance Targets
Accessibility:
- WCAG 2.1 AA: color contrast, focus outlines, keyboard navigation.
- ARIA roles for interactive components (tabs, lists, alerts).
- Reduced motion and scalable typography (rem-based).
- Proper labels for status changes (aria-live for updates).

Performance (PWA on mid-tier devices/network):
- LCP ≤ 2.5s on 4G, CLS ≤ 0.1, TTI ≤ 3.5s.
- Keep initial JS bundle minimal; code-split staff dashboards.
- Image and icon optimization; cache strategy with service worker (future).

## Security & Privacy Considerations
- Authentication: OAuth/OIDC or JWT-based sessions; secure storage; short-lived tokens.
- Authorization: Role-based rendering for staff features; guard routes and components.
- Data protection: HTTPS-only, HSTS, CORS restricted to FRONTEND_URL.
- PII minimization: Store only necessary info for notifications; allow user opt-out and delete.
- WebSocket: token-authenticated connection; auto-refresh tokens.
- XSS/CSRF: sanitize inputs, Content Security Policy, CSRF tokens for state-changing endpoints.
- Logging: Redact PII in client logs; respect telemetry disable flag.

## Rollout Plan and Feature Flags
- Phased rollout:
  - Phase 1: Passenger flight search, detail, follow, in-app notifications.
  - Phase 2: WebSocket live updates, push notifications, saved flights.
  - Phase 3: Staff dashboards, alerts, notes.
- Flags (REACT_APP_FEATURE_FLAGS):
  - flightsSearch, followNotifications, pushNotifications, opsDashboards, alertsCenter, staffNotes, experiments.
- Experiments:
  - Alternative search result layouts; different notification prompts.
- Kill switches:
  - Remotely disable push or WS features if instability detected.

## Open Questions and Dependencies
- Confirm flight data providers and SLA for update frequency and latency.
- Define push provider (FCM web, OneSignal, or custom).
- Authentication flows and identity provider selection.
- Map provider for live tracking (if map view adopted) and licensing.
- Backend contracts for alerts and notes (schemas and audit requirements).

## Acceptance Criteria (End-to-End)
- The PWA renders on mobile and desktop, adheres to Ocean Professional theme, and meets accessibility targets (AA).
- Passenger users can search, view details, and follow flights; receive in-app notifications; push enabled where permitted.
- Staff users (after auth) can access dashboards, view alerts, acknowledge/resolve them, and add notes.
- Real-time updates are applied via WebSocket within 5 seconds; polling fallback operates every 30 seconds when WS unavailable.
- Analytics and telemetry are emitted for core flows and performance; health check endpoint configured.
- Feature flags allow enabling/disabling staff dashboards, alerts, and push without redeploy.
- Security controls in place: HTTPS, authN/authZ, token-secured WS, sanitized UI.

## Suggested Screen Inventory
- Passenger
  - Flights Home (Search + Saved)
  - Search Results
  - Flight Detail (Status + Timeline/Live Tracking)
  - Notification Center
  - Preferences (Notifications, Accessibility)
- Staff
  - Ops Dashboard (Inbound/Outbound boards + KPIs)
  - Alerts Center
  - Flight Detail (with Staff Notes)
  - Admin/Settings (Feature Flags visibility)

