# Changelog

Internal dev notes for Grouper. Not part of the published site (excluded from the Cloudflare deploy).

## 2026-07-06

Six fixes/features, all in `index.html` (single-file app, no build step):

1. **Sidebar class rows.** Class names were single-line and got cut off with an ellipsis
   (`overflow:hidden; white-space:nowrap`), and the rename/delete icons competed with the
   name for the same row's width. Rows are now two lines: name (wraps up to 2 lines via
   `-webkit-line-clamp`) + count on top, rename/delete icons on their own row below.
   Sidebar widened 212px -> 236px to give names more room.

2. **Collapsible panels.** Both the classes sidebar and the roster panel can now be
   collapsed to a 44px rail (chevron to re-expand) so the groups grid gets more width on
   smaller screens. State persists (`sidebarCollapsed` / `rosterCollapsed` in local
   storage) so it stays collapsed across reloads. Roster collapse only applies on desktop;
   mobile already has its own Groups/Roster tab switch.

3. **Roles edit button was clipping off-screen.** The header was a single non-wrapping
   flex row (`height:60, flex:'0 0 60px'`, no `flexWrap`), so on narrower windows the
   later buttons (Roles edit pencil, Generate, Export, Present) got pushed past the visible
   edge. Header now wraps (`flexWrap:'wrap'`, `minHeight:60`) instead of clipping, so every
   control is reachable at any window width, not just the pencil icon specifically.

4. **Balance levels, actually wired in.** This was UI-only before: the toggle existed and
   passed `balance:true` into the generator, but the cost function scored a candidate
   group by its *existing* members' average level and completely ignored the level of the
   student being placed - so it could never actually push high/low students toward the
   groups that needed them. Fixed to score the group's average level *after* hypothetically
   adding the candidate, and raised the weight so it's a real force (verified: variance of
   group-average level across a synthetic 30-student roster dropped from ~0.14 to ~0.05
   with the toggle on, vs. ~0.11 either way before the fix).
   - Added a **Levels** modal (pencil icon next to the Balance levels chip) where a teacher
     sets each student's level (Support / Core / Extend, stored as 1-3 on `student.level`).
     Students were previously assigned a *random* level with no way to see or change it.
   - `student.level` is teacher-only by design and must never render in Stage (the student
     projector view), exports, or print - confirmed neither currently reference it, and
     both the field's comment and this note exist so a future change doesn't add it there
     by accident.

5. **BTC roles preset.** Added "BTC" (Building Thinking Classrooms) to the Roles presets
   alongside Classic/Discussion/Lab/Jigsaw: `Marker holder (silent scribe)`, `Speaker`,
   `Speaker` - one marker holder who writes only what others say, everyone else talks and
   passes the marker.

6. **Save status was invisible.** Every change was already saved to `localStorage`
   (`rgg.v3`) on every state change, but nothing ever told you that, so it wasn't obvious
   whether anything had actually persisted. Added a `SaveIndicator` pill in the header
   (Saving.../Saved/Not saved, with a tooltip giving the last-saved time and making clear
   this is browser-local only, nothing leaves the page) driven by a 300ms-debounced save
   effect. `saveState()` now returns true/false so a `localStorage` failure (quota/private
   mode) surfaces as "Not saved" instead of failing silently.

Verified all six in-browser (desktop, 780px narrow, and mobile 375px widths) with no
console errors before shipping.

## 2026-07-07

Six more, all in `index.html` / `styles.css`:

1. **Tightened side columns.** Sidebar 236px -> 214px, roster 268px -> 242px, giving the
   groups grid more width. Safe to go narrower than the 2026-07-06 widths because the
   2-line class-name wrap (from that pass) no longer needs extra width to avoid clipping.

2. **Group card headers decluttered.** Removed the flat 10x10 color-square dot. Member
   rows un-indented: dropped the leading drag-handle (grip) icon, so avatar/name/role/pin
   shift left and role labels that were tight on space now have full room. Dragging still
   works - the grip icon was purely a visual affordance, the row itself is what's
   `draggable`.

3. **Group number as a badge.** Replaced the plain "GROUP 1" text treatment with a
   circular number badge styled like the student `Avatar` component (colored circle, bold
   white number) + a smaller de-emphasized "GROUP" label. Combines with #2: the number
   badge fills the same visual slot the color-square dot used to occupy.

4. **Same badge treatment in Present/Stage mode**, sized up for projector viewing
   (`clamp(30px,2.8vw,40px)` circles), replacing the small square dot there too.
   `--stage-bg` darkened `#1F1535` -> `#120B1F` (near-black, keeps the purple hue) to
   match the darker chrome she pointed at.

5. **Role switcher on the Present screen ("Rotate roles").** New button (icon: undo/rotate)
   + `R` keyboard shortcut in Stage's control bar, shown only when Roles is on. Shifts
   which role each seat in every group holds by one position, round-robin
   (`RN[(j + roleShift) % RN.length]`), without touching group membership - this is "pass
   the marker" for BTC classes, or just role rotation for any Roles preset. State
   (`roleShift`) is local to the Stage component, so it resets each time you re-enter
   Present (a fresh session starts the rotation over); it does NOT affect the Work view's
   role display, which stays fixed to the original top-down assignment.
   NOTE: her request said "roll switcher" - read as "role switcher" given the whole
   surrounding request is about Roles and her BTC marker-pass ritual (see
   `dlk-thinking-classrooms-grouper` in Claude's memory). Flagged to her in case that
   reading is wrong.

6. **Teacher and Term.** New always-visible fields in the sidebar (`TEACHER` / `TERM`,
   each with its own edit pencil opening a small modal - `RenameModal` generalized with a
   `title`/`placeholder` prop rather than a new component). Global to the whole app (not
   per-class), persisted alongside everything else in `localStorage`.

Verified all six in-browser (desktop, 780px narrow, mobile 375px) with no console errors;
confirmed role rotation via both the button and the `R` key, confirmed `teacherName`/`term`
round-trip through `localStorage`.

## 2026-07-07 (later)

Five follow-ups on the same day's pass, all in `index.html`:

1. **Roster narrowed further.** 242px -> 210px, more room for the groups grid again.

2. **Roster "Edit" button is icon-only now** (pencil + `title`/`aria-label` tooltip, no
   visible "Edit" text) - matches the pattern every other small utility icon in the app
   already used (Roles-edit pencil, Balance-levels-edit pencil, class-row rename/delete,
   panel-collapse chevrons). Audited the rest of the app for the same icon+redundant-text
   pattern before touching anything else: didn't find another instance - everything else
   with a text label next to an icon is a primary action (Generate/Export/Present/Add
   class/Add role) or a modal footer button, where keeping the label is the right call, not
   an oversight.

3. **Fixed the group header word order.** The 2026-07-06 badge redesign put the number
   badge BEFORE the word "GROUP" (read as "2 Group"). Swapped so the label comes first and
   the badge sits after it ("GROUP 2"), in both the work-view `GroupCard` and the Present
   `Stage` header - same fix in both places since both got the badge treatment together
   last time.

4. **Rotate roles: added backward stepping + an "Edit roles" trigger, reusing the exact
   editor the setup screen uses.** `rotateRoles()` became `stepRoles(dir)` (`dir` is +1 or
   -1); UI is now a 3-part pill (back-chevron / Rotate roles / edit-pencil) instead of one
   button. `Shift+R` steps backward (`R` alone still steps forward). The edit-pencil calls
   the SAME `onEditRoles` handler the Toolbar's Roles-edit pencil already used
   (`setModal({type:'roles'})` in App, unchanged) - so it opens the actual
   `RolesEditorModal` (presets, add/remove/reorder/rename roles, save-as-default) as an
   overlay on top of Present mode, and any rename saves and reflects immediately in the
   projected groups. No new editor component; this is 100% reuse.
   GOTCHA hit while wiring this: the Toolbar's Roles-edit pencil and the new Stage one
   both have `title="Edit role names"`. The Toolbar's copy stays mounted (just visually
   covered) while Stage is open, so a CSS-selector-based click can silently land on the
   WRONG (hidden) one - harmless here since both call the identical handler, but worth
   remembering next time two same-titled buttons can coexist in the DOM: scope the
   selector (e.g. query within `[data-stage="yes"]`) rather than a bare global one.

5. **Roster/sidebar widths just kept shrinking each pass** - if she asks again, the
   remaining lever is letting the groups grid reduce its column count on narrow windows
   (currently fixed at 4 columns once a class has more than 6 groups, regardless of
   available width); that's a real pre-existing responsive gap, not something touched in
   either 2026-07-06 or 2026-07-07, flagged here for whenever it comes up.

Verified in-browser (desktop, 780px narrow) with no console errors; confirmed rotate
forward/back both work, confirmed the Edit-roles overlay opens correctly over the darkened
Present background and a rename saves + reflects live in the projected groups.

## 2026-07-07 (later still)

**Fixed: "group size" mode could strand exactly one student alone.** With 19 students and
group size 2, the generator picked `G = ceil(19/2) = 10` groups, split as evenly as
possible - 9 pairs plus one group of 1 (whoever didn't fit). She flagged this from a
screenshot: she'd have had to manually bump group size to 3 just to keep everyone paired,
which defeats the point of asking for size 2 in the first place.

Root cause, in `generateGroups` (`index.html`): even-splitting `n` students across `G`
groups always produces two possible sizes, `base` and `base+1` (`base = floor(n/G)`). When
`base === 1`, the "short" groups end up at size 1 - which is only ever a real problem when
the requested size is 2 (`base+1 = 2 = value`, so `base = 1` IS a lone student). For size
3+ the short groups still land on 2+ members, never truly alone.

Fix: after computing the initial `G` for size mode, walk it down one at a time while it
would still produce a mixed group of exactly 1 (`base === 1 && extra > 0`), stopping as
soon as it wouldn't (or at `G === 1`). For 19 @ size 2 this drops `G` from 10 to 9, giving
one group of 3 and eight pairs - nobody alone, and she never has to touch the group-size
control to get there.

Deliberately scoped to "group size" mode only, NOT "# of groups" mode: an explicit group
COUNT (e.g. "I have 6 stations") is a structural choice she's making on purpose, so it's
left exactly as requested even if it produces a small group - silently overriding a
number she typed in felt like the wrong call, unlike size mode where the count is only
ever a means to a target size. If she ever wants the same protection in count mode, revisit.

Also correctly leaves alone the two genuinely-intentional cases: a class of 1 present
student (unavoidable, nothing to rebalance against) and an explicit group size of 1
(everyone solo on purpose - `extra === 0` in that case, so the "mixed sizes" check never
fires).

Verified: swept every combination of 1-25 students x group sizes 2-4 in-browser (0
violations - no run produced a lone student next to bigger groups); spot-checked her exact
scenario (19 students, size 2) six consecutive re-shuffles, always `[3,2,2,2,2,2,2,2,2]`;
confirmed size-1 requests and n=1 classes are left untouched; confirmed count mode is
unaffected (7 students, "6 groups" still gives `[2,1,1,1,1,1]`, unchanged from before).
No console errors.
