exports.StatusBar = class iOSStatusBar extends Layer
	
	HEIGHT = 40
	WIDTH = Framer.Device.screen.width
	LIGHT = "light"
	DARK  = "dark"

	constructor: (@options) ->
		@options ?= {}
		@options.backgroundColor ?= "transparent"
		super @options
		@.height = HEIGHT
		@.width  = WIDTH
		
		return if navigator.standalone
		# This code below shouldn't be used if in standalone mode since it gets included automatically
		
		@options.shade ?= LIGHT
		@options.shade  = LIGHT if @options.shade isnt LIGHT and @options.shade isnt DARK
		
		imgLeft   = "modules/StatusBar-assets/status-#{@options.shade}-left.png"
		imgMiddle = "modules/StatusBar-assets/status-#{@options.shade}-middle.png"
		imgRight  = "modules/StatusBar-assets/status-#{@options.shade}-right.png"
		
		@statusLeft   = new Layer superLayer: @, image: imgLeft,   width: 130, height: HEIGHT
		@statusMiddle = new Layer superLayer: @, image: imgMiddle, width: 108, height: HEIGHT, x: WIDTH/2-108/2
		@statusRight  = new Layer superLayer: @, image: imgRight,  width: 130, height: HEIGHT, x: WIDTH-130