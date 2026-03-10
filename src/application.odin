#+feature using-stmt
package main

import "Fizzle3D:debug"
import "Fizzle3D:graphics"
import "Fizzle3D:scene"
import gl "vendor:OpenGL"
import "vendor:glfw"

TITLE :: "Fizzle3D"
GL_MAJOUR_VERSION :: 4
GL_MINOR_VERSION :: 6

Application :: struct {
	handle:                           glfw.WindowHandle,
	menu:                             scene.Menu,
	last_frame, current_frame, delta: f64,
}

Application_Run :: proc(application: ^Application) {
	using application, debug, glfw
	if !initialize(application) {
		critical("APPLICATION: Unable to initialize, panic!")
		return
	}
	set_callbacks(handle)
	load_assets(application)

	for !WindowShouldClose(handle) {
		update(application)
		render(application)
	}
}

Application_Destroy :: proc(application: ^Application) {
	using application, graphics, scene, glfw
	Menu_Destroy(&menu)
	DestroyWindow(handle)
	Terminate()
}

@(private = "file")
initialize :: proc(application: ^Application) -> bool {
	using debug, application, scene, graphics, glfw
	if !Init() {
		critical("GLFW: Unable to initialize")
		return false
	}
	WindowHint(CLIENT_API, OPENGL_API)
	WindowHint(RESIZABLE, TRUE)
	WindowHint(OPENGL_FORWARD_COMPAT, TRUE)
	WindowHint(OPENGL_PROFILE, OPENGL_CORE_PROFILE)
	WindowHint(CONTEXT_VERSION_MAJOR, GL_MAJOUR_VERSION)
	WindowHint(CONTEXT_VERSION_MINOR, GL_MINOR_VERSION)

	primary := GetPrimaryMonitor()
	if primary == nil {
		critical("GLFW: No primary monitor found")
		return false
	}
	mode := GetVideoMode(primary)

	handle = CreateWindow(mode.width, mode.height, TITLE, primary, nil)
	if handle == nil {
		critical("GLFW: Unable to create window")
		return false
	}

	MakeContextCurrent(handle)
	SwapInterval(1)

	gl.load_up_to(GL_MAJOUR_VERSION, GL_MINOR_VERSION, gl_set_proc_address)

	gl.Enable(gl.BLEND)
	gl.BlendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA)

	menu = Menu_Create()
	return true
}

@(private = "file")
load_assets :: proc(application: ^Application) {
	using application, scene, graphics
	Menu_LoadAssets(&menu)

}

@(private = "file")
update :: proc(application: ^Application) {
	using application, scene, glfw
	current_frame = GetTime()
	delta = current_frame - last_frame
	last_frame = current_frame
	PollEvents()
	Menu_Update(&menu)

}

@(private = "file")
render :: proc(application: ^Application) {
	using application, graphics, scene, glfw
	gl.ClearColor(rgba255(255, 0, 147, 255))
	gl.Clear(gl.COLOR_BUFFER_BIT)

	Menu_Render(&menu)

	SwapBuffers(handle)
}

@(private = "file")
rgba255 :: #force_inline proc "contextless" (r, g, b, a: f32) -> (f32, f32, f32, f32) {
	return r / 255.0, g / 255.0, b / 255.0, a / 255.0
}

@(private = "file")
key_callback :: proc "c" (window: glfw.WindowHandle, key, scancode, action, mods: i32) {
	using glfw
	if key == KEY_ESCAPE && action == PRESS {
		SetWindowShouldClose(window, true)
	}
}

@(private = "file")
size_callback :: proc "c" (window: glfw.WindowHandle, width, height: i32) {
	gl.Viewport(0, 0, width, height)
}

@(private = "file")
set_callbacks :: proc(window: glfw.WindowHandle) {
	using glfw
	SetKeyCallback(window, key_callback)
	SetFramebufferSizeCallback(window, size_callback)
}

