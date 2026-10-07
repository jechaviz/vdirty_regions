module vdirty_regions

pub struct Rect {
pub:
	x int
	y int
	w int
	h int
}

pub struct Plan {
pub:
	regions     []Rect
	dirty_area  i64
	viewport    Rect
	pressure    string
	reason      string
	full_redraw bool
}

pub fn (rect Rect) valid() bool {
	return rect.w > 0 && rect.h > 0
}

pub fn (rect Rect) area() i64 {
	if !rect.valid() {
		return 0
	}
	return i64(rect.w) * i64(rect.h)
}

pub fn (rect Rect) contains(x int, y int) bool {
	return x >= rect.x && y >= rect.y && x < rect.x + rect.w && y < rect.y + rect.h
}

pub fn intersects(a Rect, b Rect) bool {
	if !a.valid() || !b.valid() {
		return false
	}
	return a.x < b.x + b.w && a.x + a.w > b.x && a.y < b.y + b.h && a.y + a.h > b.y
}

pub fn touches(a Rect, b Rect, gap int) bool {
	g := if gap > 0 { gap } else { 0 }
	return a.x <= b.x + b.w + g && a.x + a.w + g >= b.x
		&& a.y <= b.y + b.h + g && a.y + a.h + g >= b.y
}

pub fn union(a Rect, b Rect) Rect {
	if !a.valid() {
		return b
	}
	if !b.valid() {
		return a
	}
	x1 := min_int(a.x, b.x)
	y1 := min_int(a.y, b.y)
	x2 := max_int(a.x + a.w, b.x + b.w)
	y2 := max_int(a.y + a.h, b.y + b.h)
	return Rect{x: x1, y: y1, w: x2 - x1, h: y2 - y1}
}

pub fn clip(rect Rect, bounds Rect) Rect {
	if !rect.valid() || !bounds.valid() {
		return Rect{}
	}
	x1 := max_int(rect.x, bounds.x)
	y1 := max_int(rect.y, bounds.y)
	x2 := min_int(rect.x + rect.w, bounds.x + bounds.w)
	y2 := min_int(rect.y + rect.h, bounds.y + bounds.h)
	if x2 <= x1 || y2 <= y1 {
		return Rect{}
	}
	return Rect{x: x1, y: y1, w: x2 - x1, h: y2 - y1}
}

pub fn plan_regions(input []Rect, max_regions int, viewport_w int, viewport_h int) Plan {
	viewport := Rect{x: 0, y: 0, w: max_int(0, viewport_w), h: max_int(0, viewport_h)}
	if !viewport.valid() {
		return Plan{viewport: viewport, reason: 'empty_viewport', pressure: 'none'}
	}
	mut regions := []Rect{}
	for rect in input {
		clipped := clip(rect, viewport)
		if clipped.valid() {
			merge_into(mut regions, clipped, 1)
		}
	}
	if regions.len == 0 {
		return Plan{viewport: viewport, reason: 'clean', pressure: 'none'}
	}
	limit := if max_regions > 0 { max_regions } else { 64 }
	for regions.len > limit {
		merge_closest_pair(mut regions)
	}
	mut area := i64(0)
	for rect in regions {
		area += rect.area()
	}
	viewport_area := viewport.area()
	if viewport_area > 0 && area * 100 >= viewport_area * 70 {
		return Plan{
			regions: [viewport]
			dirty_area: viewport_area
			viewport: viewport
			pressure: 'high'
			reason: 'dirty_area_threshold'
			full_redraw: true
		}
	}
	pressure := if regions.len * 100 >= limit * 80 {
		'high'
	} else if regions.len * 100 >= limit * 40 {
		'medium'
	} else {
		'low'
	}
	return Plan{
		regions: regions
		dirty_area: area
		viewport: viewport
		pressure: pressure
		reason: 'partial'
	}
}

fn merge_into(mut regions []Rect, candidate Rect, gap int) {
	mut merged := candidate
	mut i := 0
	for i < regions.len {
		if touches(regions[i], merged, gap) {
			merged = union(regions[i], merged)
			regions.delete(i)
			i = 0
			continue
		}
		i++
	}
	regions << merged
}

fn merge_closest_pair(mut regions []Rect) {
	if regions.len < 2 {
		return
	}
	mut best_i := 0
	mut best_j := 1
	mut best_cost := union(regions[0], regions[1]).area() - regions[0].area() - regions[1].area()
	for i := 0; i < regions.len; i++ {
		for j := i + 1; j < regions.len; j++ {
			cost := union(regions[i], regions[j]).area() - regions[i].area() - regions[j].area()
			if cost < best_cost {
				best_cost = cost
				best_i = i
				best_j = j
			}
		}
	}
	regions[best_i] = union(regions[best_i], regions[best_j])
	regions.delete(best_j)
}

fn min_int(a int, b int) int {
	return if a < b { a } else { b }
}

fn max_int(a int, b int) int {
	return if a > b { a } else { b }
}
