#+feature using-stmt
package scene


import "Fizzle3D:debug"
import "Fizzle3D:graphics"
import "core:fmt"
import "core:strings"
import gl "vendor:OpenGL"
import "vendor:glfw"

Menu :: struct {
	button: [3]graphics.Texture2D,
	shader: graphics.Shader,
	quad:   graphics.Quad,
}


Menu_Create :: proc() -> Menu {
	using debug, graphics
	shader := Shader_Create(VERT_SRC, FRAG_SRC)
	quad := Quad_Create()


	return Menu{shader = shader, quad = quad}

}

Menu_Destroy :: proc(menu: ^Menu) {
	using menu, graphics, glfw

	for &btn in &button {
		Texture2D_Destroy(&btn)
	}
	Shader_Destroy(&shader)
	Quad_Destroy(&quad)

}
Menu_LoadAssets :: proc(menu: ^Menu) {
	using debug, graphics, menu

	for i in 0 ..< len(button) {
        concat := strings.clone_to_cstring(fmt.tprintf("assets/btn%d.png", i))
        defer delete(concat)
		button[i] = Texture2D_Load(concat)
	}
}


Menu_Update :: proc(menu: ^Menu) {
	using debug, menu

}
Menu_Render :: proc(menu: ^Menu) {
	using debug, menu, graphics

	for btn in button {
		if btn.visible {
			Shader_Use(shader)
			gl.ActiveTexture(gl.TEXTURE0)
			gl.BindTexture(gl.TEXTURE_2D, btn.id)
			gl.Uniform1i(gl.GetUniformLocation(shader.program, "u_texture"), 0)
			Quad_Draw(quad)
		}
	}
}

