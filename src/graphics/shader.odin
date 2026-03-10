#+feature using-stmt
package graphics

import "Fizzle3D:debug"
import gl "vendor:OpenGL"
import "core:math/linalg"

VERT_SRC :: `#version 460 core
layout(location = 0) in vec2 a_pos;
layout(location = 1) in vec2 a_uv;
out vec2 v_uv;
uniform mat4 u_projection;
uniform mat4 u_model;
void main() {
    gl_Position = u_projection * u_model * vec4(a_pos, 0.0, 1.0);
    v_uv = a_uv;
}`

FRAG_SRC :: `#version 460 core
in vec2 v_uv;
out vec4 frag_color;
uniform sampler2D u_texture;
void main() {
    frag_color = texture(u_texture, v_uv);
}`

Shader :: struct {
    program: u32,
}

Shader_Create :: proc(vert_src, frag_src: string) -> Shader {
    using debug
    vert := compile_shader(vert_src, gl.VERTEX_SHADER)
    frag := compile_shader(frag_src, gl.FRAGMENT_SHADER)
    defer gl.DeleteShader(vert)
    defer gl.DeleteShader(frag)

    program := gl.CreateProgram()
    gl.AttachShader(program, vert)
    gl.AttachShader(program, frag)
    gl.LinkProgram(program)
    ok: i32
    gl.GetProgramiv(program, gl.LINK_STATUS, &ok)
    if ok == 0 {
        log: [512]u8
        gl.GetProgramInfoLog(program, 512, nil, raw_data(log[:]))
        error("SHADER LINK: %s", cstring(raw_data(log[:])))
    }
    return Shader{program = program}
}

Shader_Use  :: proc(s: Shader) { gl.UseProgram(s.program) }

Shader_Set_Int :: proc(s: Shader, name: cstring, v: i32) {
    gl.Uniform1i(gl.GetUniformLocation(s.program, name), v)
}

Shader_Set_Mat4 :: proc(s: Shader, name: cstring, m: linalg.Matrix4f32) {
    loc := gl.GetUniformLocation(s.program, name)
    m   := m  // local copy — now addressable
    gl.UniformMatrix4fv(loc, 1, gl.FALSE, cast([^]f32)&m)
}

Shader_Destroy :: proc(s: ^Shader) {
    gl.DeleteProgram(s.program)
    s^ = {}
}

@(private = "file")
compile_shader :: proc(src: string, type: u32) -> u32 {
    using debug
    shader   := gl.CreateShader(type)
    src_cstr := cstring(raw_data(src))
    length   := i32(len(src))
    gl.ShaderSource(shader, 1, &src_cstr, &length)
    gl.CompileShader(shader)
    ok: i32
    gl.GetShaderiv(shader, gl.COMPILE_STATUS, &ok)
    if ok == 0 {
        log: [512]u8
        gl.GetShaderInfoLog(shader, 512, nil, raw_data(log[:]))
        error("SHADER COMPILE: %s", cstring(raw_data(log[:])))
    }
    return shader
}

