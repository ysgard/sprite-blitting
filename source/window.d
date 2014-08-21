/**
 * Contains the Window class, which manages an SDL window.
 *
 * Derived from: <a href="http://twinklebeardev.blogspot.ca/2012/09/lesson-7-taking-advantage-of-classes.html">
 * 				twinklebeardev's SDL2 Tutorial</a>
 *
 */

import derelict.sdl2.sdl;
import derelict.sdl2.image;
import derelict.sdl2.ttf;
import std.file;
import std.path;
import std.string;

import util;


class Window {

 	// Private methods
 	SDL_Window* mWindow;
 	SDL_Renderer* mRenderer;
 	SDL_Rect mBox;
 	bool active;


 	/**
 	 * Call to create a new window
 	 * @param title The caption of the window
	 * @param width The width of the window
	 * @param height The height of the window
 	 */
 	this(string title, int width, int height) {

 		// Setup window
 		mBox.x = 0;
 		mBox.y = 0;
 		mBox.w = width;
 		mBox.h = height;

 		// Create our window
 		mWindow = SDL_CreateWindow(toStringz(title), SDL_WINDOWPOS_CENTERED,
 			SDL_WINDOWPOS_CENTERED, mBox.w, mBox.h, SDL_WINDOW_SHOWN | SDL_WINDOW_OPENGL );
 		if (mWindow == null) {
 			throw new Exception(SDLErrorStr("Could not create new window!"));
 		}

 		// Create the renderer
 		mRenderer = SDL_CreateRenderer(mWindow, -1, SDL_RENDERER_ACCELERATED);
 		if (mRenderer == null) {
 			throw new Exception(SDLErrorStr("Could not create rendered for window!"));
 		}

 		// We're up an running
 		active = true;
 	}

 	/// Terminate the window
 	~this() {
 		SDL_DestroyRenderer(mRenderer);
 		SDL_DestroyWindow(mWindow);
 		active = false;
 	}

 	/**
 	*  Draw a SDL_Texture to the screen at dstRect with various other options
	*  @param tex The SDL_Texture to draw
	*  @param dstRect The destination position and width/height to draw the texture with
	*  @param clip The clip to apply to the image, if desired
	*  @param angle The rotation angle to apply to the texture, default is 0
	*  @param xPivot The x coordinate of the pivot, relative to (0, 0) being center of dstRect
	*  @param yPivot The y coordinate of the pivot, relative to (0, 0) being center of dstRect
	*  @param flip The flip to apply to the image, default is none
	*/
	void draw(SDL_Texture *tex,
						SDL_Rect dstRect,
						SDL_Rect *clip,
						float angle,
						int xPivot,
						int yPivot,
						SDL_RendererFlip flip) {

		// Convert pivot pos from relative to the object's center to screen space
		xPivot += dstRect.w / 2;
		yPivot += dstRect.h / 2;
		// SDL expects an SDL_Point as the pivot location
		SDL_Point pivot = { xPivot, yPivot };
		// Draw the texture
		SDL_RenderCopyEx(mRenderer, tex, clip, &dstRect, angle, &pivot, flip);
	}

 	/**
	*  Generate a texture containing the message we want to display
	*  @param message The message we want to display
	*  @param fontFile The font we want to use to render the text
	*  @param color The color we want the text to be
	*  @param fontSize The size we want the font to be
	*  @return An SDL_Texture* to the rendered message
	*/
	SDL_Texture* renderText(string message, string fontFile,
		SDL_Color color, int fontSize) {

		if (!exists(fontFile)) {
			throw new Exception(format("RenderText: Font file %s does not exist!\n", fontFile));
		}

		// Open the font
		auto font = TTF_OpenFont(toStringz(fontFile), fontSize);
		if (font == null) {
			throw new Exception(format("RenderText: Could not load font %s: %s", fontFile, TTF_GetError()));
		}
		scope(exit) { TTF_CloseFont(font); }

		// Render the message to an SDL_Surface
		auto surf = TTF_RenderText_Blended(font, toStringz(message), color);
		scope(exit) { SDL_FreeSurface(surf); }
		auto tex = SDL_CreateTextureFromSurface(mRenderer, surf);

		return tex;
	}

	/**
	* LoadTexture takes the string of an image file and used LoadImage to obtain
	* the surface, which it then converts to a texture using the provied
	* renderer.  The texture is then returned.
	* @param file The file containing the texture we want to load.
	* @return An SDL_Texture* pointing to the loaded texture.
	*/
	SDL_Texture* loadTexture(string file) {

		SDL_Texture* tex = null;
		auto sfc = loadImage(file);
		scope(exit) {
			SDL_FreeSurface(sfc);
		}
		tex = SDL_CreateTextureFromSurface(mRenderer, sfc);
		if (tex) {
			return tex;
		} else {
			throw new Exception(format("LoadImage: Unable to convert texture: %s", IMG_GetError()));
		}
	}

	/**
	* Clear the renderer
	*/
	void clear() {
		SDL_RenderClear(mRenderer);
	}

	/**
	* Present the renderer, i.e., update screen
	*/
	void present() {
		SDL_RenderPresent(mRenderer);
	}

	/**
	* Update mBox to match the current window size
	*/
	SDL_Rect box() {
		SDL_GetWindowSize(mWindow, &mBox.w, &mBox.h);
		return mBox;
	}

	/**
	* Is the Window initialized and active?
	* @return running state
	*/
	bool isActive() {
		return active;
	}

  SDL_Renderer* renderer() {
		return mRenderer;
  }

	SDL_Window* window() {
		return mWindow;
	}
}
