package graphics

import gl "vendor:OpenGL"
import "core:math/linalg"

Quad :: struct {
    vao, vbo, ebo: u32,
}

Quad_Create :: proc() -> Quad {
    // Unit quad: (0,0) to (1,1) so model matrix maps directly to pixels
    vertices := [16]f32{
        0.0, 0.0,  0.0, 0.0,
        1.0, 0.0,  1.0, 0.0,
        1.0, 1.0,  1.0, 1.0,
        0.0, 1.0,  0.0, 1.0,
    }
    indices := [6]u32{0, 1, 2, 2, 3, 0}

    q: Quad
    gl.GenVertexArrays(1, &q.vao)
    gl.GenBuffers(1, &q.vbo)
    gl.GenBuffers(1, &q.ebo)

    gl.BindVertexArray(q.vao)

    gl.BindBuffer(gl.ARRAY_BUFFER, q.vbo)
    gl.BufferData(gl.ARRAY_BUFFER, size_of(vertices), &vertices, gl.STATIC_DRAW)

    gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, q.ebo)
    gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, size_of(indices), &indices, gl.STATIC_DRAW)

    stride := i32(4 * size_of(f32))
    gl.VertexAttribPointer(0, 2, gl.FLOAT, gl.FALSE, stride, 0)
    gl.EnableVertexAttribArray(0)
    gl.VertexAttribPointer(1, 2, gl.FLOAT, gl.FALSE, stride, uintptr(2 * size_of(f32)))
    gl.EnableVertexAttribArray(1)

    gl.BindVertexArray(0)
    return q
}

// Draw at pixel coordinates. x,y = top-left corner, w,h = pixel size.
Quad_Draw :: proc(q: Quad, s: Shader, x, y, w, h: f32) {
    model := linalg.matrix4_translate_f32({x, y, 0}) *
             linalg.matrix4_scale_f32({w, h, 1})
    Shader_Set_Mat4(s, "u_model", model)
    gl.BindVertexArray(q.vao)
    gl.DrawElements(gl.TRIANGLES, 6, gl.UNSIGNED_INT, nil)
    gl.BindVertexArray(0)
}

Quad_Destroy :: proc(q: ^Quad) {
    gl.DeleteVertexArrays(1, &q.vao)
    gl.DeleteBuffers(1, &q.vbo)
    gl.DeleteBuffers(1, &q.ebo)
    q^ = {}
}

