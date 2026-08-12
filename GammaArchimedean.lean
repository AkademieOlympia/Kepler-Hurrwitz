/-
Copyright (c) 2026 Kepler-Hurrwitz contributors. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kepler-Hurrwitz Team
-/

import GammaArchimedean.DeligneIdentity
import GammaArchimedean.ParityChannels
import GammaArchimedean.ChannelCoupling

/-!
# GammaArchimedean

Archimedean Deligne Γ-factors as a sealed Lean lib.

Lake root reexport (same pattern as `KeplerHurwitz.lean`).

Conceptual package layout:

```
GammaArchimedean/
├── DeligneIdentity.lean   -- Level 1 [A]: Mathlib anchor
├── ParityChannels.lean    -- Level 2 [A]: U/V channels
└── ChannelCoupling.lean   -- Level 3 [C]: scaffold + non-claims
```

Independent of `KeplerHurwitz.Core` — do not import Collatz / Core here.
-/
