/**
 * sprite-blitting
 *
 * A sample app to explore how to leverage SDL2's functions to perform
 * sprite bltting from a spritesheet to a window, as well as performing
 * color transformations on it.
 *
 * Author: Jan (ysgard) Van Uytven, ysgard@gmail.com
 * @2014
 */

import std.stdio;
import std.string;

// Derelict2
import derelict.sdl2.sdl;
import derelict.sdl2.image;
import derelict.sdl2.ttf;

import util;
import window;

immutable WINDOW_WIDTH = 1200;
immutable WINDOW_HEIGHT = 800;


int main()
{
	// Load the SDL2 Libraries
	DerelictSDL2.load();
	DerelictSDL2Image.load();
	DerelictSDL2ttf.load();

	// Initialize
	if (SDL_Init(SDL_INIT_EVERYTHING == -1)) {
		writefln(SDLErrorStr("Could not initialize SDL!"));
	}
	if (TTF_Init() == -1) {
		writefln(SDLErrorStr("Could not initialize TTF_SDL!"));
	}
	scope(exit) {
		SDL_Quit();
		TTF_Quit();
	}

	// Create a window
	auto main_window = new Window("Sprite Blitting", WINDOW_WIDTH, WINDOW_HEIGHT);

	// Create a debugging window to catch log messages
	auto debug_window = new Window("Debug Window", 800, 300);

	// Load the spritesheet texture - use the main window's renderer.
	auto sprite_sheet = main_window.loadTexture("data/BrogueFont5.png");

	// Get information about the spritesheet and the window
	SDL_Rect window_size = { 0, 0, 0, 0 };
	SDL_Rect sheet_size = { 0, 0, 0, 0 };
	if (SDL_QueryTexture(sprite_sheet, null, null, &sheet_size.w, &sheet_size.h)) {
		writefln(SDLErrorStr("Error getting the size of the spritesheet texture"));
	}
	SDL_GetWindowSize(main_window.window(), &window_size.w, &window_size.h);

	// Create the clip rectangle we want to blit the spritesheet into
	SDL_Rect clip_rect = { (window_size.w - sheet_size.w) / 2,
												 (window_size.h - sheet_size.h) / 2,
												 sheet_size.w, sheet_size.h };
	
	
	// Main event loop
	bool quit = false;
	while (!quit) {
		SDL_Event e;
		while (SDL_PollEvent(&e)) {
			// If the user closes the window, break and exit
			switch (e.type) {
			case SDL_QUIT:
				quit = true;
				break;
			case SDL_MOUSEBUTTONDOWN:
				quit = true;
				break;
			default:
				break;
			}
		}
		main_window.clear();
		debug_window.clear();

		// Blit the spritesheet texture into the window at the coords of the clip rectangle
		if(SDL_RenderCopy(main_window.renderer(), sprite_sheet, null, &clip_rect)) {
			writefln(SDLErrorStr("Could not blit spritesheet to window!"));
		}
		
		main_window.present();
		debug_window.present();
	}
	return 0;
}
