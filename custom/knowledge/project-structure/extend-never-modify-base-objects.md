---
bc-version: [all]
domain: project-structure
keywords: [extension, tableextension, pageextension, event-subscriber, base-application, customization, modify]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Extend the base application, never modify it

## Description

Business Central customizations reach standard behaviour through three, and only three, sanctioned shapes: a `tableextension`/`pageextension`/`reportextension`/`enumextension` on the base object, an event subscriber on a published base event, or a new object of your own. Re-declaring a base object under its own ID, shipping an altered copy of base source into the extension, or reaching into base internals any other way is outside the extension model.

The failure is not stylistic. A modified or re-declared base object does not survive a platform upgrade: Microsoft ships a new version of that object and your copy either collides on ID, silently shadows the supported implementation, or blocks installation. The extension model exists precisely so that a monthly base-application update cannot invalidate partner code, and stepping outside it forfeits that guarantee for the whole extension, not just the offending object.

This convention also constrains *how* an extension participates in base logic: subscribe to what the base publishes rather than re-implementing a base routine so it can be called instead. A re-implemented posting routine is a copy of base logic by another name and decays the same way.

## Best Practice

Add fields and controls with `tableextension` / `pageextension` on the base object. Hook behaviour with `[EventSubscriber(ObjectType::…, …)]` against a published base event, matching the publisher's exact signature. Put genuinely new behaviour in new objects inside the extension's own ID range. When the base application publishes no suitable event, request one upstream rather than working around its absence — an unsupported workaround is a permanent liability, a missing event is a temporary one.

See `extend-never-modify-base-objects.good.al`.

## Anti Pattern

Declaring `table 18 Customer` (or any base ID) in extension source; pasting base-object source into the extension and editing it; re-implementing a base routine so callers can be redirected to the copy; or altering base behaviour by any means other than an extension object or a published event. See `extend-never-modify-base-objects.bad.al`.
