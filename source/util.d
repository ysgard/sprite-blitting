// Utility functions for SDL2

import derelict.sdl2.sdl;
import derelict.sdl2.image;
import derelict.sdl2.ttf;
import std.file;
import std.path;
import std.string;

/**
*  Loads an image directly to texture using SDL_image's
*  built in function IMG_Load
*  @param file The image file to load
*  @return SDL_Surface* to the loaded image
*/
SDL_Surface* loadImage(string file) {
	 // Do some quick checking on the file - does it exist?
	// Does it have an extension? (needed for IMG_Load)
	if ( !(exists(file) && extension(file).length)) {
		throw new Exception(format("LoadImage: file %s does not exist or does not have an image extension.", file));
	}

	auto sfc = IMG_Load(toStringz(file));
	if (sfc == null) {
		throw new Exception(format("LoadImage: Unable to load image %s - %s",
			file, IMG_GetError()));
	}
	return sfc;
 }

/**
* LoadTexture takes the string of an image file and used LoadImage to obtain
* the surface, which it then converts to a texture using the provied
* renderer.  The texture is then returned.
* @param ren The rendering context to convert the texture with.
* @param file The file containing the texture we want to load.
* @return An SDL_Texture* pointing to the loaded texture.
*/
static SDL_Texture* loadTexture(SDL_Renderer* ren, string file) {

    SDL_Texture* tex = null;
    auto sfc = loadImage(file);
    scope(exit) {
        SDL_FreeSurface(sfc);
    }
    tex = SDL_CreateTextureFromSurface(ren, sfc);
    if (tex) {
        return tex;
    } else {
        throw new Exception(format("LoadImage: Unable to convert texture: %s", IMG_GetError()));
    }
}


/**
 * Apply surface takes a texture and applies it to a rendering context at the provided
 * x, y coordinates.
 */
void applySurface(int x, int y, SDL_Texture *texture, SDL_Renderer *render, SDL_Rect *clip = null) {
	SDL_Rect pos;
	pos.x = x;
	pos.y = y;

	// Detect if we should use clip width settings or texture width.
	if (clip != null) {
		pos.w = clip.w;
		pos.h = clip.h;
	} else {
		SDL_QueryTexture(texture, null, null, &pos.w, &pos.h);
	}
	SDL_RenderCopy(render, texture, clip, &pos);
}

/**
 * Generate an error string using a user-provided message, the output of the last SDL Error will
 * also be displayed.
 *
 * @param msg A user-provided string to use
 * @return A string containing the user-provided message and the last SDL error logged.
 */
string SDLErrorStr(string msg) {
	return format("SDL Error -> %s\n%s", msg, SDL_GetError());
}
