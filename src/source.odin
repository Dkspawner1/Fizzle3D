#+feature using-stmt
package main
import "Fizzle3D:debug"
import "core:mem"
import "vendor:glfw"

main :: proc() {
	using debug, glfw

	Logger_Initialize(.DEBUG)
	defer Logger_Shutdown()


	track: mem.Tracking_Allocator
	mem.tracking_allocator_init(&track, context.allocator)
	context.allocator = mem.tracking_allocator(&track)

	info("DEBUG MODE ACTIVE - Memory tracking enabled")

	defer {
		debug("=== Memory Report ===")
		leak_count := len(track.allocation_map)
		bad_free_count := len(track.bad_free_array)
		for _, leak in track.allocation_map {
			error("Leaked %v bytes @ %v", leak.size, leak.location)
		}
		for bad_free in track.bad_free_array {
			error("Bad free @ %p from %v", bad_free.memory, bad_free.location)
		}
		if leak_count > 0 {
			critical("=== %v MEMORY LEAKS DETECTED ===", leak_count)
		} else if bad_free_count > 0 {
			critical("=== %v BAD FREES DETECTED ===", bad_free_count)
		} else {
			info("No memory leaks detected")
		}
		mem.tracking_allocator_destroy(&track)
	}


	application := Application{}
	defer Application_Destroy(&application)
	Application_Run(&application)

}

