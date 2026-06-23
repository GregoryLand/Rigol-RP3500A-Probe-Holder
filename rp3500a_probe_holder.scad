/*
* SPDX-License-Identifier: CC-BY-NC-SA-4.0
* SPDX-FileCopyrightText: 2026 Gregory Land
*
* RP3500A scope probe holder for ERGO-FLEXI-FIX helping-hands arms.
*
* This design uses ERGO-FLEXI-FIX geometry by FokieH_Print as a mount
* interface. ERGO-FLEXI-FIX is licensed under CC BY-NC-SA 4.0.
*/
use <./reference/rp3500a-model/rp3500a_probe.scad>
$fn = 72;

PROBE_DIAMETER = 10.0;
PROBE_CLEARANCE = 0.50;

HOLDER_LENGTH = 45.0;
WALL_THICKNESS = 2.5;
BASE_THICKNESS = 3.0;
LIP_HEIGHT = 3.0;

STRAP_COUNT = 2;
STRAP_WIDTH = 4.4;
STRAP_INSET_FROM_END = 10.0;

module cradle_solid(holder_length, body_width, body_height, r=2.0) {
	size = [holder_length, body_width, body_height];
	hull() {
		for (sx = [-1, 1], sy = [-1, 1]) {
			translate([sx * (size[0]/2 - r), sy * (size[1]/2 - r), 0])
				cylinder(r=r, h=size[2]);
		}
	}
}

module cradle_cut(slot_width, body_height, base_thickness, holder_length) {
	translate([0,0, body_height/2 + base_thickness])
		cube([holder_length + 2, slot_width, body_height], center=true);
}

module at_strap_positions(holder_length, strap_count, strap_inset_from_end) {
	assert(strap_count >= 0 && strap_count <= 2, "STRAP_COUNT must be 0, 1, or 2");
	if (strap_count == 1) {
		translate([0, 0, 0]) children();
	}
	else if (strap_count == 2) {
		for (xpos = [-holder_length/2 + strap_inset_from_end, holder_length/2 - strap_inset_from_end]) {
			translate([xpos, 0, 0]) children();
		}
	}
}

module zip_tie_notches(body_width, body_height, holder_length, strap_width, strap_count, strap_inset_from_end, cut_depth = 1.0) {
	if (strap_count > 0 && cut_depth > 0) {
		at_strap_positions(holder_length, strap_count, strap_inset_from_end) {
			translate([0, 0, body_height - (cut_depth/2) + 0.01])
				cube([strap_width, body_width + 2, cut_depth + 0.04], center=true);
			translate([0, 0, (cut_depth/2) - 0.01])
				cube([strap_width, body_width + 2, cut_depth + 0.04], center=true);
		}
	}
}

module ergo_flexi_fix_flexi_element() {
	// ERGO-FLEXI-FIX by FokieH_Print
	// License: CC-BY-NC-SA-4.0
	// Source: https://www.printables.com/model/824414-ergo-flexi-fix
	translate([0,0,-79])
		import(file="./reference/ergo-flexi-fix/010_Flexi-Element.stl");
}

module flexi_mount() {
	CUBE_SIZE = 15;
	difference() {
		ergo_flexi_fix_flexi_element();
		translate([-(CUBE_SIZE/2),-(CUBE_SIZE/2),13]) cube([CUBE_SIZE,CUBE_SIZE,CUBE_SIZE]);
	}
}

module cradle_probe_front_stop(slot_width)
{
	cube_size = 2;

	translate([0,-(slot_width/2),0])
		cube([cube_size, slot_width, cube_size]);
}

module cradle_probe_ground_lead_slot(cutout_width=8.0, ground_lead_width=5.0)
{
	translate([0,-(cutout_width/2),0])
		cube([ground_lead_width,cutout_width,10]);
}

module rp3500a_probe_holder(probe_diameter, probe_clearance, holder_length, base_thickness, wall_thickness, lip_height, strap_count, strap_width, strap_inset_from_end) {
	// probe_clearance only widens the cradle slot. Wall height is tuned by lip_height and we use probe_diameter to get in the ballpark.
	probe_keepout = probe_diameter + (probe_clearance * 2);
	body_height = base_thickness + (probe_diameter / 2) + lip_height;
	body_width  = probe_keepout + (wall_thickness * 2);

	union() {
		difference(){
			cradle_solid(holder_length, body_width, body_height);
			cradle_cut(probe_keepout, body_height, base_thickness, holder_length);
			zip_tie_notches(body_width, body_height, holder_length, strap_width, strap_count, strap_inset_from_end);
			translate([15.5,0,-5])
				cradle_probe_ground_lead_slot();
		}
		translate([20.5,0,3])
			cradle_probe_front_stop(probe_keepout + 1);
		translate([0,0,-13])
			flexi_mount();
	}
}

translate([0,0,8])
	rotate([0,90,0])
		%rp3500a_probe();

rp3500a_probe_holder(PROBE_DIAMETER, PROBE_CLEARANCE, HOLDER_LENGTH, BASE_THICKNESS, WALL_THICKNESS, LIP_HEIGHT, STRAP_COUNT, STRAP_WIDTH, STRAP_INSET_FROM_END);
