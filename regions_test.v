module vdirty_regions

fn test_clip_and_union_rect() {
	bounds := Rect{x: 0, y: 0, w: 100, h: 100}
	assert clip(Rect{x: -10, y: -10, w: 30, h: 30}, bounds) == Rect{x: 0, y: 0, w: 20, h: 20}
	assert union_rect(Rect{x: 0, y: 0, w: 10, h: 10}, Rect{x: 8, y: 8, w: 10, h: 10}) == Rect{x: 0, y: 0, w: 18, h: 18}
}

fn test_plan_merges_overlaps() {
	plan := plan_regions([Rect{x: 0, y: 0, w: 20, h: 20}, Rect{x: 19, y: 0, w: 20, h: 20}], 64, 200, 100)
	assert plan.regions.len == 1
	assert !plan.full_redraw
}
