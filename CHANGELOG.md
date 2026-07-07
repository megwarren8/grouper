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
