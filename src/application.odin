#+feature using-stmt
package main

import "Fizzle3D:debug"
import "Fizzle3D:graphics"
import "base:runtime"
import "core:fmt"
import "core:math/linalg"
import "core:strings"
import gl "vendor:OpenGL"
import "vendor:glfw"

TITLE :: "Fizzle3D"
GL_MAJOUR_VERSION :: 4
GL_MINOR_VERSION :: 6

Application :: struct {
	handle:                           glfw.WindowHandle,
	buttons:                          [3]graphics.Texture2D,
	shader:                           graphics.Shader,
	quad:                             graphics.Quad,
	projection:                       linalg.Matrix4f32,
	last_frame, current_frame, delta: f64,
}

Application_Run :: proc(application: ^Application) {
	using application, debug, glfw
	if !initialize(application) {
		critical("APPLICATION: Unable to initialize, panic!")
		return
	}
	set_callbacks(handle, application)
	load_assets(application)

	for !WindowShouldClose(handle) {
		update(application)
		render(application)
	}
}

Application_Destroy :: proc(application: ^Application) {
	using application, graphics, glfw
	for &button in &buttons {
		Texture2D_Destroy(&button)

	}
	Shader_Destroy(&shader)
	Quad_Destroy(&quad)
	DestroyWindow(handle)
	Terminate()
}

@(private = "file")
make_ortho :: proc(w, h: f32) -> linalg.Matrix4f32 {
	// left=0, right=w, bottom=h, top=0 → (0,0) top-left, Y down
	return linalg.matrix_ortho3d_f32(0, w, h, 0, -1, 1)
}

@(private = "file")
initialize :: proc(application: ^Application) -> bool {
	using debug, application, graphics, glfw
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

	projection = make_ortho(f32(mode.width), f32(mode.height))
	shader = Shader_Create(VERT_SRC, FRAG_SRC)
	quad = Quad_Create()
	return true
}

@(private = "file")
load_assets :: proc(application: ^Application) {
	using debug, application, graphics
	for i in 0 ..< len(buttons) {
		path := fmt.ctprintf("assets/btn%d.png", i)
		buttons[i] = Texture2D_Load(path)
	}
}

@(private = "file")
update :: proc(application: ^Application) {
	using application, glfw
	current_frame = GetTime()
	delta = current_frame - last_frame
	last_frame = current_frame
	PollEvents()
}

@(private = "file")
render :: proc(application: ^Application) {
	using application, graphics, glfw
	gl.ClearColor(rgba255(255, 0, 147, 255))
	gl.Clear(gl.COLOR_BUFFER_BIT)
	for i := 0; i < len(buttons); i += 1 {

		if buttons[i].visible {
			Shader_Use(shader)
			Shader_Set_Mat4(shader, "u_projection", projection)
			Shader_Set_Int(shader, "u_texture", 0)
			gl.ActiveTexture(gl.TEXTURE0)
			gl.BindTexture(gl.TEXTURE_2D, buttons[i].id)

			Quad_Draw(
				quad,
				shader,
				5,
				175.0 + (f32(i) * 130.0),
				f32(buttons[i].width / 4.0),
				f32(buttons[i].height / 4.0),
			)
		}
	}

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
	context = runtime.default_context()
	gl.Viewport(0, 0, width, height)
	app := cast(^Application)glfw.GetWindowUserPointer(window)
	if app != nil {
		app.projection = make_ortho(f32(width), f32(height))
	}
}


@(private = "file")
set_callbacks :: proc(window: glfw.WindowHandle, app: ^Application) {
	using glfw
	SetWindowUserPointer(window, app)
	SetKeyCallback(window, key_callback)
	SetFramebufferSizeCallback(window, size_callback)
}

