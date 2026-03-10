#+feature using-stmt
package graphics

import "Fizzle3D:debug"
import gl "vendor:OpenGL"
import "vendor:stb/image"

Texture2D :: struct {
    path:          cstring,
    width, height: i32,
    id:            u32,
    visible:       bool,
}

Texture2D_Load :: proc(path: cstring) -> Texture2D {
    using debug
    image.set_flip_vertically_on_load(1)
    width, height, channels: i32
    data := image.load(path, &width, &height, &channels, 4)
    if data == nil {
        critical("IMAGE: Failed to load: %s", path)
        return {}
    }
    defer image.image_free(data)

    id: u32
    gl.GenTextures(1, &id)
    gl.BindTexture(gl.TEXTURE_2D, id)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S,     i32(gl.CLAMP_TO_EDGE))
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T,     i32(gl.CLAMP_TO_EDGE))
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, i32(gl.LINEAR_MIPMAP_LINEAR))
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, i32(gl.LINEAR))
    gl.TexImage2D(gl.TEXTURE_2D, 0, gl.RGBA8, width, height, 0, gl.RGBA, gl.UNSIGNED_BYTE, data)
    gl.GenerateMipmap(gl.TEXTURE_2D)

    return Texture2D{path = path, width = width, height = height, id = id, visible = true}
}

Texture2D_Destroy :: proc(t: ^Texture2D) {
    gl.DeleteTextures(1, &t.id)
    t^ = {}
}

