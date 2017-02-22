#Import input, mapbox, and any other modules
InputModule = require "input"
{ mapboxgl } = require "npm"
ui = require "StatusBar"
#product = require "product"

data = JSON.parse Utils.domLoadDataSync "data.json" #Load JSON
products = data["products"] #store products into products
zips = data["zipcodes"] #store zipcodes into zips

#Availability
for product in products
	availInZips = [] #An array of zipcodes that the product is available in
	
	#A random number from 0 to the number of zipcodes
	randNum = () => Math.round("#{Utils.randomNumber(0, zips.length)}")
	
	#Loop for randum number of times for each product
	for i in [0..randNum()]
	
		aZip = zips[randNum()] #get a random zipcode from the arrazy of zip codes
		availInZips.push aZip #add the zip code to the array of zipcodes available for this product
	
	product.availInZips = availInZips #add the availInZips array to eact product

#Lat and Long
Long = [-104.997633,
		-104.982650,
		-105.020395,
		-104.962829,
		-104.952592,
		-104.916613,
		-104.965750,
		-104.962315,
		-105.019736,
		-105.048027,
		-105.069025,
		-105.115977
		-104.956478]

Lat = [ 39.751907,
		39.731686,
		39.734837,
		39.758857,
		39.730282,
		39.762298,
		39.706581,
		39.676626,
		39.767444,
		39.772047,
		39.743312,
		39.744773,
		39.788551]

#Map
accessToken = "pk.eyJ1Ijoibml0aW45MyIsImEiOiJjaXpkanB5bmkyN3VtMnFxcDBtcjRqdW9sIn0.1y5PHv0USetteJFnMb1lHA"

mapStyle = "mapbox://styles/nitin93/cizdjzd3b009j2so5roxtlam1"

# Creating a new HTML layer
# for the map to live inside of and scale
# it to fit the entire window
mapHeight = Screen.height
mapWidth = Screen.width

mapboxLayer = new Layer
mapboxLayer.ignoreEvents = false
mapboxLayer.width = mapWidth
mapboxLayer.height = mapHeight
mapboxLayer.html = "<div id='map'></div>"
mapElement = mapboxLayer.querySelector("#map")
mapElement.style.height = mapHeight + 'px'

mapboxgl.accessToken = "#{accessToken}"

map = new mapboxgl.Map({
	container: mapElement
	zoom: 11
	center: [-104.997633, 39.751907]
	# here we're using a default style:
	# you can use any of the defaults or a
	# custom style you design in Mapbox Studio
	style: "#{mapStyle}"
	hash: true
})




#Status Bar
statusBar = new ui.StatusBar shade: "dark", backgroundColor: ""

#Input
input = new InputModule.Input
	setup: false # Change to true when positioning the input so you can see it
	virtualKeyboard: true # Enable or disable virtual keyboard for when viewing on computer
	placeholder: "Enter your zipcode" # Text visible before the user type
	placeholderColor: "gray" # Color of the placeholder text
	#text: "Some text" # Initial text in the input
	type: "text" # Use any of the available HTML input types. Take into account that on the computer the same keyboard image will appear regarding the type used.
	backgroundColor: "white"
	borderRadius: 10
	fontSize: 30
	lineHeight: 30
	paddingLeft: 40
	paddingTop: 20
	paddingBottom: 20
	shadowY: 25
	shadowX: 20
	shadowBlur: 10
	shadowSpread: 20
	shadowColor: "rgba(0,0,0,0.2)"

	y: 70
	minX: 50
	width: 610
	height: 60
	goButton: false # Set true here in order to use "Go" instead of "Return" as button (only works on real devices)

input.states = 
	inactive:
		opacity: .7
		shadowY: 25
		shadowX: 20
		shadowBlur: 10
		shadowSpread: 20
	active:
		opacity: 1
		shadowY: 30
		shadowX: 20
		shadowBlur: 40
		shadowSpread: 30

input.stateSwitch("inactive")

#Sign Up
signupText = new Layer
	width: 400
	height: 100
	x: 290
	y: 70
	backgroundColor: ""
	visible: false

Utils.labelLayer(signupText, "We don't deliver there yet!")

signupText.style.color = "black"
signupText.style.textShadow = "10px 20px #000;"

signup = new Layer
	width: 400
	height: 100
	x: Align.center
	y: 220
	backgroundColor: "#000140"
	borderRadius: 50
	shadowY: 1
	shadowBlur: 15
	shadowSpread: 10
	shadowColor: "rgba(0,1,64,0.2)"
	visible: false


Utils.labelLayer(signup, "Sign up")

availProducts = []

numOfAvail = new Layer
	width: 600
	height: 100
	x: Align.center
	y: 220
	backgroundColor: "#000140"
	borderRadius: 50
	shadowY: 1
	shadowBlur: 15
	shadowSpread: 10
	shadowColor: "rgba(0,1,64,0.2)"
	visible: false

input.on "keyup", ->
	#@value is the value of the text input
	myZip = @value
	#myNumZip = Number(myZip)

	#weDeliverThere is a boolean that checks if myZip is an available zipcode
	weDeliverThere = myZip in zips


	#if your zip is less than or more than 5 characters i.e not a zip
	if myZip.length > 5 || myZip.length < 5
		availProducts = []
		numOfAvail.visible = false

	#if we don't deliver to your zip and your zip is 5 characters long => sign up page
	else if weDeliverThere == false && myZip.length == 5
		signupText.visible = true
		signup.visible = true
		numOfAvail.visible = false

	#If we do deliver to your zip and your zip is 5 characters long
	else if weDeliverThere == true && myZip.length == 5
		signupText.visible = false
		signup.visible = false

		#get coordinates from zip codes
		zipsPos = zips.indexOf myZip
		zipLong = Long[zipsPos]
		zipLat = Lat[zipsPos]
		#zoom map to zip code
		map.flyTo({
			center: [zipLong, zipLat]
			zoom: 14,
			curve: 1,
		})

		for product in products
			productIsAvail = myZip in product.availInZips
			if productIsAvail == true
				availProducts.push product
				#load products in productResults

		numOfAvail.visible = true
		Utils.labelLayer(numOfAvail, availProducts.length + " products available in your area")

input.onFocus ->
	input.animate("active")
	#print "Input is focused and has the value: #{@value}"

productContainer = new ScrollComponent
		width: Screen.width
		height: 500
		maxY: Screen.height
		backgroundColor: "none"
		scrollVertical: false
		speedX: .5
		visible: false

productContainer.contentInset =
	top: 40
	right: 20
	bottom: 40
	left: 0

productContainer.style.background = "-webkit-linear-gradient(top, rgba(0,1,64,0) 40%, rgba(0,1,64,.7) 100%)"

images = []

disable = (layer) ->
	layer.animate
		properties: 
			opactiy: .5

#disable(layer) for layer in images

populateProducts = ->
	for i in [0...availProducts.length]
		image = new Layer
			width: 250
			height: 250
			borderRadius: 125
			x: 40 + 280 * i
			y: 100
			image: "https://d1kqgnt0l5kod0.cloudfront.net/products/February_2017/testing/20170110_february_taylor_storefront_testing.jpg"
			parent: productContainer.content
			scale: 1
			shadowY: 15
			shadowBlur: 45
			shadowColor: "rgba(0,0,0,.5)"
		
		images.push image

		image.states = 
			selected:
				y: 40
				animationOptions:
					curve: Spring(damping: 0.5)
					time: 0.5
			deselected:
				y: 100
				animationOptions:
					curve: Spring(damping: 0.5)
					time: 0.5

		image.on Events.Click, (event, layer) ->
			layer.stateCycle("selected", "deselected")
			Utils.labelLayer(numOfAvail, "Enter your address")

		title = new Layer
			parent: image
			width: 250
			height: 50
			x: Align.center
			y: 270
			backgroundColor: ""

		Utils.labelLayer(title, "#{availProducts[i].name}")
		
		title.style =
			"fontSize": "30px",
			"fontWeight": "500",
			"color": "white",
			"padding": "10px"

input.onBlur ->
	Utils.labelLayer(numOfAvail, "Pick your Bouquet")
	input.animate("inactive")

	productContainer.visible = true
	populateProducts()

