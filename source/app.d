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
		main_window.Clear();
		debug_window.Clear();
		
		main_window.Present();
		debug_window.Present();
	}
	return 0;
}
