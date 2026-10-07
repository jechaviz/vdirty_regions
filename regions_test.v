module vdirty_regions

fn test_clip_and_union() {
	bounds := Rect{0, 0, 100, 100}
	assert clip(Rect{-10, -10, 30, 30}, bounds) == Rect{0, 0, 20, 20}
	assert union(Rect{0, 0, 10, 10}, Rect{8, 8, 10, 10}) == Rect{0, 0, 18, 18}
}

fn test_plan_merges_overlaps() {
	plan := plan_regions([Rect{0, 0, 20, 20}, Rect{19, 0, 20, 20}], 64, 200, 100)
	assert plan.regions.len == 1
	assert !plan.full_redraw
}
