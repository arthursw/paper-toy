$(document).ready( ->
	canvas = document.getElementById('paperCanvas')

	paperWidth = 21
	paperHeight = 29.7
	paperRatio = paperWidth / paperHeight

	paperScale = 50
	canvas.width = paperWidth * paperScale
	canvas.height = paperHeight * paperScale
	
	console.log canvas.height
	
	paper.setup canvas
	paper.install(window)

	global = {}
	global.drag = false
	global.dragOffset = false
	global.selectionRectangle = null
	global.selectedShape = null
	global.shapes = []
	global.shapeType = 'cuboid'
	global.shapeTypes = ['cuboid', 'cone', 'pyramid', 'prism', 'cylindre', 'tetrahedron', 'house', 'car']

	gui = new dat.GUI()

	# gui = new dat.GUI( autoPlace: false )
	# customContainer = document.getElementById('dat.gui')
	# customContainer.appendChild(gui.domElement)

	size = {}
	size.paperZoom = 1
	size.tabSize = 10
	size.scale = 2
	size.width = 30 		# a
	size.depth = 20 		# b
	size.height = 10 		# c
	size.length1 = 15
	size.length2 = 25
	size.length3 = 15
	size.length4 = 15
	size.length5 = 15
	size.radius = 6

	initialize = ()->

		# adapt paper size to canvas
		paperRectangle = new Rectangle(new Point(0, 0), new Size(0, 0))

		canvasRatio = view.size.width / view.size.height
		if paperRatio > canvasRatio
			paperRectangle.width = view.size.width
			paperRectangle.height = paperRectangle.width / paperRatio
		else
			paperRectangle.height = view.size.height
			paperRectangle.width = paperRectangle.height * paperRatio

		paperRectangle = paperRectangle.expand(-20)
		paperRectangle.center = view.center

		paperRectanglePath = new Path.Rectangle(paperRectangle)
		paperRectanglePath.strokeColor = 'black'
		paperRectanglePath.strokeWidth = 2
		view.center = paperRectangle.center
		global.paperPath = paperRectanglePath
		global.paperRectangle = paperRectangle
		return

	initialize()

	updateShape = ()->
		if not global.selectedShape?
			return
		position = global.selectedShape.position
		switch global.shapeType
			when 'cuboid'
				drawCuboid(global.selectedShape)
			when 'cone'
				drawCone(global.selectedShape)
			when 'pyramid'
				drawPyramid(global.selectedShape)
			when 'prism'
				drawPrism(global.selectedShape)
			when 'cylindre'
				drawCylindre(global.selectedShape)
			when 'tetrahedron'
				drawTetrahedron(global.selectedShape)
			when 'house'
				drawHouse(global.selectedShape)
			when 'car'
				drawCar(global.selectedShape)

		background = new Path.Rectangle(global.selectedShape.bounds)
		background.fillColor = 'white'
		background.fillColor.alpha = 0
		global.selectedShape.addChild(background)
		background.sendToBack()
		global.selectedShape.position = position
		global.selectionRectangle?.remove()
		global.selectionRectangle = new Path.Rectangle(global.selectedShape.bounds)
		global.selectionRectangle.strokeColor = 'blue'
		view.draw()
		return

	global.addShape = ()->
		shape = new Group()
		global.shapes.push(shape)
		global.selectedShape = shape
		updateShape()
		shape.bounds.center = global.paperRectangle.center
		global.selectionRectangle.position = shape.position
		return

	global.removeShape = ()->
		if not global.selectedShape?
			return
		global.selectedShape.remove()
		global.selectionRectangle.remove()
		global.selectedShape = null
		global.selectionRectangle = null
		return

	tool = new paper.Tool()

	mouseMove = (event)->
		if global.drag
			global.selectedShape.position = event.point.add(global.dragOffset)
			global.selectionRectangle.position = global.selectedShape.position
		return

	tool.onMouseDown = (event)->
		global.selectionRectangle?.remove()
		if event.item
			global.drag = true
			global.dragOffset = event.item.bounds.center.subtract(event.point)
			global.selectionRectangle = new Path.Rectangle(event.item.bounds)
			global.selectionRectangle.strokeColor = 'blue'
			while event.item.parent != project.activeLayer
				console.log(event.item.name)
				event.item = item.parent
			global.selectedShape = event.item
			console.log(event.item.name)
			console.log(event.item)
			global.shapeType = global.selectedShape.name
			tool.onMouseMove = mouseMove
		return

	stopDrag = ()->
		global.drag = false
		tool.onMouseMove = null
		return

	tool.onMouseUp = stopDrag
	$('body').on 'mouseup', stopDrag

	createTab = (p1, p2)->
		vector = p2.subtract(p1)
		tabLength = Math.sqrt(2) * size.tabSize

		vector = vector.normalize(tabLength)
		vector = vector.rotate(45)

		path = new Path()
		path.add(p1)
		path.add(p1.add(vector))
		path.add(p2.add(vector.rotate(90)))
		path.add(p2)

		path.strokeColor = 'black'
		path.strokeWidth = 1
		return path

	drawCuboid = (cuboid)->
		cuboid.removeChildren()
		cuboid.name = 'cuboid'

		width = size.width * size.scale
		height = size.height * size.scale
		depth = size.depth * size.scale

		tabs = new Group()
		rectangle1 = new Rectangle(new Point(depth, 0), new Size(width, 2*(height+depth)))
		center = rectangle1.center
		rectangle2 = new Rectangle(new Point(0, depth), new Size(width+2*depth, height))
		cuboid.addChild(new Path.Rectangle(rectangle1))
		cuboid.addChild(new Path.Rectangle(rectangle2))
		path = new Path()
		path.add(new Point(rectangle1.left, center.y + depth))
		path.add(new Point(rectangle1.right, center.y + depth))
		cuboid.addChild(path)

		# tabs
		tab1 = new Path()
		tab1.add(new Point(rectangle1.left, rectangle1.top))
		tab1.add(new Point(rectangle1.left + size.tabSize, rectangle1.top - size.tabSize))
		tab1.add(new Point(rectangle1.right - size.tabSize, rectangle1.top - size.tabSize))
		tab1.add(new Point(rectangle1.right, rectangle1.top))

		tab2 = new Path()
		tab2.add(new Point(rectangle1.left - depth, rectangle1.top + depth))
		tab2.add(new Point(rectangle1.left - depth + size.tabSize, rectangle1.top + depth - size.tabSize))
		tab2.add(new Point(rectangle1.left - size.tabSize, rectangle1.top + depth - size.tabSize))
		tab2.add(new Point(rectangle1.left, rectangle1.top + depth))

		tab3 = new Path()
		tab3.add(new Point(rectangle1.right, rectangle1.top + depth))
		tab3.add(new Point(rectangle1.right + size.tabSize, rectangle1.top + depth - size.tabSize))
		tab3.add(new Point(rectangle1.right + depth - size.tabSize, rectangle1.top + depth - size.tabSize))
		tab3.add(new Point(rectangle1.right + depth, rectangle1.top + depth))

		tab4 = new Path()
		tab4.add(new Point(rectangle1.left, center.y))
		tab4.add(new Point(rectangle1.left - size.tabSize, center.y + size.tabSize))
		tab4.add(new Point(rectangle1.left - size.tabSize, center.y + depth - size.tabSize))
		tab4.add(new Point(rectangle1.left, center.y + depth))

		tab5 = new Path()
		tab5.add(new Point(rectangle1.right, center.y))
		tab5.add(new Point(rectangle1.right + size.tabSize, center.y + size.tabSize))
		tab5.add(new Point(rectangle1.right + size.tabSize, center.y + depth - size.tabSize))
		tab5.add(new Point(rectangle1.right, center.y + depth))

		tab6 = new Path()
		tab6.add(new Point(rectangle1.left, center.y + depth))
		tab6.add(new Point(rectangle1.left - size.tabSize, center.y + depth + size.tabSize))
		tab6.add(new Point(rectangle1.left - size.tabSize, center.y + depth + height - size.tabSize))
		tab6.add(new Point(rectangle1.left, center.y + depth + height))

		tab7 = new Path()
		tab7.add(new Point(rectangle1.right, center.y + depth))
		tab7.add(new Point(rectangle1.right + size.tabSize, center.y + depth + size.tabSize))
		tab7.add(new Point(rectangle1.right + size.tabSize, center.y + depth + height - size.tabSize))
		tab7.add(new Point(rectangle1.right, center.y + depth + height))

		tabs.addChild(tab1)
		tabs.addChild(tab2)
		tabs.addChild(tab3)
		tabs.addChild(tab4)
		tabs.addChild(tab5)
		tabs.addChild(tab6)
		tabs.addChild(tab7)

		for tab in tabs.children
			tab.strokeColor = 'black'
			tab.strokeWidth = 1

		for shape in cuboid.children
			shape.dashArray = [10, 4]
			shape.strokeColor = 'black'
			shape.strokeWidth = 1

		cuboid.addChild(tabs)

		return

	drawCone = (cone)->
		cone.removeChildren()
		cone.name = 'cone'

		height = size.height * size.scale
		radius = size.radius * size.scale
		center = new Point()
		angle = Math.min((radius / height), 0.9) * 2 * Math.PI
		from = center.add(new Point(height, 0))
		through = center.add(new Point(height * Math.cos(angle / 2), -height * Math.sin(angle / 2)))
		to = center.add(new Point(height * Math.cos(angle), -height * Math.sin(angle)))
		arc = new Path.Arc(from, through, to)

		angle = Math.min(angle, Math.PI)
		through2 = center.add(new Point(height * Math.cos(angle / 2), -height * Math.sin(angle / 2)))
		to2 = center.add(new Point(height * Math.cos(angle), -height * Math.sin(angle)))
		arc2 = new Path.Arc(from, through2, to2)
		arc2.fillColor = 'white'

		circle = new Path.Circle(new Point(center.x + height + radius, center.y), radius)
		path = new Path()
		path.add(from)
		path.add(center)
		path2 = new Path()
		path2.add(center)
		path2.add(to)
		cone.addChild(arc2)
		cone.addChild(arc)
		cone.addChild(circle)
		cone.addChild(path)
		cone.addChild(path2)

		for shape in cone.children
			shape.strokeColor = 'black'
			shape.strokeWidth = 1

		path.dashArray = [10, 4]

		circleTab = new Path.Circle(new Point(center.x + height + radius, center.y), radius+size.tabSize)
		circleTab.dashArray = [2, 2]
		circleTab.strokeColor = 'black'
		circleTab.strokeWidth = 1

		tab = new Path()
		tab.add(new Point(center))
		tab.add(new Point(center.x + size.tabSize, center.y + size.tabSize))
		tab.add(new Point(center.x + height - size.tabSize, center.y + size.tabSize))
		tab.add(new Point(center.x + height, center.y))
		tab.strokeColor = 'black'
		tab.strokeWidth = 1
		tab.fillColor = 'white'
		cone.addChild(circleTab)
		cone.addChild(tab)

		circleTab.sendToBack()

		return

	drawCylindre = (cylindre)->
		cylindre.removeChildren()
		cylindre.name = 'cylindre'

		height = size.height * size.scale
		radius = size.radius * size.scale

		center = new Point()

		rectangle = new Rectangle(center, new Size(2 * Math.PI * radius, height))
		rectanglePath = new Path.Rectangle(rectangle)
		path = new Path()
		path.add(new Point(rectangle.bottomLeft))
		path.add(new Point(rectangle.bottomRight))

		tab = new Path()
		tab.add(new Point(rectangle.topLeft))
		tab.add(new Point(rectangle.left - size.tabSize, rectangle.top + size.tabSize))
		tab.add(new Point(rectangle.left - size.tabSize, rectangle.bottom - size.tabSize))
		tab.add(new Point(rectangle.left, rectangle.bottom))

		tab2 = new Path()
		tab2.add(new Point(rectangle.topRight))
		tab2.add(new Point(rectangle.right + size.tabSize, rectangle.top + size.tabSize))
		tab2.add(new Point(rectangle.right + size.tabSize, rectangle.bottom - size.tabSize))
		tab2.add(new Point(rectangle.right, rectangle.bottom))

		tab3 = new Path()
		tab3.add(new Point(rectangle.topLeft))
		tab3.add(new Point(rectangle.left + size.tabSize, rectangle.top - size.tabSize))
		tab3.add(new Point(rectangle.right - size.tabSize, rectangle.top - size.tabSize))
		tab3.add(new Point(rectangle.topRight))

		cylindre.addChild(path)
		cylindre.addChild(createTab(rectangle.topLeft, rectangle.bottomLeft))
		cylindre.addChild(createTab(rectangle.bottomLeft, rectangle.bottomRight))
		cylindre.addChild(createTab(rectangle.topRight, rectangle.topLeft))

		circle1 = new Path.Circle(new Point(radius, rectangle.bottom + radius + size.tabSize), radius)
		circle2 = new Path.Circle(new Point(3 * radius, rectangle.bottom + radius + size.tabSize), radius)

		cylindre.addChild(circle1)
		cylindre.addChild(circle2)
		cylindre.addChild(rectanglePath)

		for child in cylindre.children
			child.strokeColor = 'black'
			child.strokeWidth = 1
			child.fillColor = 'white'

		tab.dashArray = [2, 2]
		tab2.dashArray = [2, 2]

		rectanglePath.strokeColor = 'black'
		rectanglePath.strokeWidth = 1
		rectanglePath.dashArray = [10, 4]

		return

	drawPyramid = (pyramid)->
		pyramid.removeChildren()
		pyramid.name = 'pyramid'

		height = size.height * size.scale
		width = size.width * size.scale
		depth = size.depth * size.scale
		halfWidth = width / 2
		H = Math.sqrt(height * height + halfWidth * halfWidth)

		center = new Point()

		rectangle = new Rectangle(center, new Size(width, depth))
		rectanglePath = new Path.Rectangle(rectangle)

		path1 = new Path()
		path1.add(rectangle.topLeft)
		p1 = new Point(rectangle.center.x, rectangle.top - H)
		path1.add(p1)
		path1.add(rectangle.topRight)

		path2 = new Path()
		path2.add(rectangle.topLeft)
		p2 = new Point(rectangle.left - H, rectangle.center.y)
		path2.add(p2)
		path2.add(rectangle.bottomLeft)

		path3 = new Path()
		path3.add(rectangle.topRight)
		p3 = new Point(rectangle.right + H, rectangle.center.y)
		path3.add(p3)
		path3.add(rectangle.bottomRight)

		path4 = new Path()
		path4.add(rectangle.bottomLeft)
		p4 = new Point(rectangle.center.x, rectangle.bottom + H)
		path4.add(p4)
		path4.add(rectangle.bottomRight)

		pyramid.addChild(path1)
		pyramid.addChild(path2)
		pyramid.addChild(path3)
		pyramid.addChild(path4)
		pyramid.addChild(rectanglePath)

		for child in pyramid.children
			child.strokeColor = 'black'
			child.strokeWidth = 1
			child.dashArray = [10, 4]

		pyramid.addChild(createTab(rectangle.topRight, p1))
		pyramid.addChild(createTab(rectangle.topLeft, p2))
		pyramid.addChild(createTab(rectangle.bottomRight, p3))
		pyramid.addChild(createTab(rectangle.bottomLeft, p4))

		return

	drawPrism = (prism)->
		prism.removeChildren()
		prism.name = 'prism'

		height = size.height * size.scale
		width = size.width * size.scale
		depth = size.depth * size.scale
		length1 = size.length1 * size.scale
		length1 = Math.min(width, length1)

		widthMinusLength1 = width - length1
		h1 = Math.sqrt(length1 * length1 + height * height)
		h2 = Math.sqrt(widthMinusLength1 * widthMinusLength1 + height * height)

		center = new Point()

		rectangle = new Rectangle(center, new Size(width + h1 + h2, depth))
		rectanglePath = new Path.Rectangle(rectangle)

		path1 = new Path()
		p11 = new Point(rectangle.left + h1, rectangle.top)
		path1.add(p11)
		p12 = new Point(rectangle.left + h1, rectangle.bottom)
		path1.add(p12)

		path2 = new Path()
		p21 = new Point(rectangle.left + h1 + width, rectangle.top)
		path2.add(p21)
		p22 = new Point(rectangle.left + h1 + width, rectangle.bottom)
		path2.add(p22)

		path3 = new Path()
		path3.add(p11)
		p13 = new Point(rectangle.left + h1 + length1, rectangle.top - height)
		path3.add(p13)
		path3.add(p21)

		path4 = new Path()
		path4.add(p12)
		p23 = new Point(rectangle.left + h1 + length1, rectangle.bottom + height)
		path4.add(p23)
		path4.add(p22)

		prism.addChild(rectanglePath)
		prism.addChild(path1)
		prism.addChild(path2)
		prism.addChild(path3)
		prism.addChild(path4)

		for child in prism.children
			child.strokeColor = 'black'
			child.strokeWidth = 1
			child.dashArray = [10, 4]

		prism.addChild(createTab(p13, p11))
		prism.addChild(createTab(p21, p13))
		prism.addChild(createTab(p12, p23))
		prism.addChild(createTab(p23, p22))
		prism.addChild(createTab(rectangle.topLeft, rectangle.bottomLeft))
		return

	drawTetrahedron = (tetrahedron)->
		tetrahedron.removeChildren()
		tetrahedron.name = 'tetrahedron'
		width = size.width * size.scale
		angle = Math.PI / 3
		h = width * Math.sin(angle)

		p1 = new Point(0, 0)
		p2 = new Point(2*width, 0)
		p3 = new Point(width, 2*h)
		path1 = new Path()
		path1.add(p1)
		path1.add(p2)
		path1.add(p3)
		path1.add(p1)

		p4 = new Point(width, 0)
		p5 = new Point(width * 1.5, h)
		p6 = new Point(width * 0.5, h)
		path2 = new Path()
		path2.add(p4)
		path2.add(p5)
		path2.add(p6)
		path2.add(p4)

		tetrahedron.addChild(path1)
		tetrahedron.addChild(path2)

		for child in tetrahedron.children
			child.strokeColor = 'black'
			child.strokeWidth = 1
			child.dashArray = [10, 4]

		tetrahedron.addChild(createTab(p4, p1))
		tetrahedron.addChild(createTab(p5, p2))
		tetrahedron.addChild(createTab(p6, p3))
		return

	drawHouse = (house)->
		house.removeChildren()
		house.name = 'house'

		height = size.height * size.scale
		width = size.width * size.scale
		depth = size.depth * size.scale
		length1 = size.length1 * size.scale
		length2 = size.length2 * size.scale

		delta1 = Math.sqrt(length1 * length1 + depth * depth)
		delta2 = Math.sqrt(length2 * length2 + depth * depth)

		center = new Point()

		rectangle = new Rectangle(center, new Size(2 * (width + length1 + length2), height))
		rectanglePath = new Path.Rectangle(rectangle)
		floor = new Rectangle(new Point(0, rectangle.bottom), new Size(width, length1 + length2))
		floorPath = new Path.Rectangle(floor)

		path1 = new Path()
		path1.add(rectangle.topLeft)
		p1 = new Point(rectangle.left, rectangle.top - delta1)
		path1.add(p1)
		p2 = new Point(rectangle.left + width, rectangle.top - delta1)
		path1.add(p2)
		p3 = new Point(rectangle.left + width, rectangle.bottom)
		path1.add(p3)
		p4 = new Point(rectangle.left + width, rectangle.top)
		path1.add(p4)
		p5 = new Point(rectangle.left + width + length1, rectangle.top - depth)
		path1.add(p5)
		p6 = new Point(rectangle.left + width + length1 + length2, rectangle.top)
		path1.add(p6)
		p7 = new Point(rectangle.left + width + length1 + length2, rectangle.bottom)
		path1.add(p7)
		p8 = new Point(rectangle.left + width + length1 + length2, rectangle.top - delta2)
		path1.add(p8)
		p9 = new Point(rectangle.left + width + length1 + length2 + width, rectangle.top - delta2)
		path1.add(p9)
		p10 = new Point(rectangle.left + width + length1 + length2 + width, rectangle.bottom)
		path1.add(p10)
		p11 = new Point(rectangle.left + width + length1 + length2 + width, rectangle.top)
		path1.add(p11)
		p12 = new Point(rectangle.left + width + length1 + length2 + width + length2, rectangle.top - depth)
		path1.add(p12)
		path1.add(rectangle.topRight)

		house.addChild(rectanglePath)
		house.addChild(floorPath)
		house.addChild(path1)

		for child in house.children
			child.strokeColor = 'black'
			child.strokeWidth = 1
			child.dashArray = [10, 4]

		house.addChild(createTab(rectangle.topLeft, rectangle.bottomLeft))
		house.addChild(createTab(p5, p4))
		house.addChild(createTab(p6, p5))
		house.addChild(createTab(p9, p8))
		house.addChild(createTab(p12, p11))
		house.addChild(createTab(rectangle.topRight, p12))
		house.addChild(createTab(p3, p7))
		house.addChild(createTab(p7, p10))
		house.addChild(createTab(p10, rectangle.bottomRight))
		return

	drawCar = (car)->
		car.removeChildren()
		car.name = 'car'

		radius = size.radius * size.scale
		height = size.height * size.scale
		width = size.width * size.scale
		depth = size.depth * size.scale
		length1 = size.length1 * size.scale
		length2 = size.length2 * size.scale
		length3 = size.length3 * size.scale
		length4 = size.length4 * size.scale
		length5 = size.length5 * size.scale

		heightPlusDepth = height + depth

		delta1 = Math.sqrt(length1 * length1 + height * height)
		delta3 = Math.sqrt(length3 * length3 + depth * depth)
		delta5 = Math.sqrt(length5 * length5 + heightPlusDepth * heightPlusDepth)

		center = new Point()
		rectangle1 = new Rectangle(center, new Size(length1, width/2))
		rectanglePath1 = new Path.Rectangle(rectangle1)
		rectangle2 = new Rectangle(rectangle1.topRight, new Size(delta1, width/2))
		rectanglePath2 = new Path.Rectangle(rectangle2)
		rectangle3 = new Rectangle(rectangle2.topRight, new Size(length2, width/2))
		rectanglePath3 = new Path.Rectangle(rectangle3)
		rectangle4 = new Rectangle(rectangle3.topRight, new Size(delta3, width/2))
		rectanglePath4 = new Path.Rectangle(rectangle4)
		rectangle5 = new Rectangle(rectangle4.topRight, new Size(length4, width/2))
		rectanglePath5 = new Path.Rectangle(rectangle5)
		rectangle6 = new Rectangle(rectangle5.topRight, new Size(delta5, width/2))
		rectanglePath6 = new Path.Rectangle(rectangle6)
		rectangle7 = new Rectangle(rectangle6.topRight, new Size(length1, width/2))
		rectanglePath7 = new Path.Rectangle(rectangle7)
		path = new Path()
		path.add(rectangle5.bottomLeft)
		p1 = new Point(rectangle5.left - length3, rectangle5.bottom + depth)
		path.add(p1)
		p2 = new Point(rectangle5.left - length3 - length2, rectangle5.bottom + depth)
		path.add(p2)
		p3 = new Point(rectangle5.left - length3 - length2 - length1, rectangle5.bottom + depth + height)
		path.add(p3)
		p4 = new Point(rectangle5.left - length3 - length2 + radius, rectangle5.bottom + depth + height)
		path.add(p4)
		p5 = new Point(rectangle5.left - length3 - length2 + radius + radius, rectangle5.bottom + depth + height)
		path.add(p5)
		p6 = new Point(rectangle5.right + length5 - length1 - radius - radius, rectangle5.bottom + depth + height)
		path.add(p6)
		p7 = new Point(rectangle5.right + length5 - length1 - radius, rectangle5.bottom + depth + height)
		path.add(p7)
		p8 = new Point(rectangle5.right + length5, rectangle5.bottom + depth + height)
		path.add(p8)
		path.add(rectangle5.bottomRight)

		wheel1 = new Path.Circle(p4, radius)
		wheel2 = new Path.Circle(p7, radius)


		car.addChild(rectanglePath1)
		car.addChild(rectanglePath2)
		car.addChild(rectanglePath3)
		car.addChild(rectanglePath4)
		car.addChild(rectanglePath5)
		car.addChild(rectanglePath6)
		car.addChild(rectanglePath7)
		car.addChild(path)
		car.addChild(wheel1)
		car.addChild(wheel2)

		for child in car.children
			child.strokeColor = 'black'
			child.strokeWidth = 1
			child.dashArray = [10, 4]

		wheel1.fillColor = 'white'
		wheel2.fillColor = 'white'
		wheel1.dashArray = null
		wheel2.dashArray = null

		car.addChild(createTab(rectangle1.bottomLeft, rectangle1.bottomRight))
		car.addChild(createTab(rectangle2.bottomLeft, rectangle2.bottomRight))
		car.addChild(createTab(rectangle3.bottomLeft, rectangle3.bottomRight))
		car.addChild(createTab(rectangle4.bottomLeft, rectangle4.bottomRight))
		car.addChild(createTab(rectangle6.bottomLeft, rectangle6.bottomRight))
		car.addChild(createTab(rectangle7.bottomLeft, rectangle7.bottomRight))
		carClone = car.clone()
		carClone.scale(1, -1)
		carClone.position.y = car.bounds.top - (car.bounds.height/2)
		car.addChild(carClone)
		whiteStripe = new Path()
		whiteStripe.add(rectangle1.topLeft)
		whiteStripe.add(rectangle7.topRight)
		whiteStripe.strokeColor = "white"
		whiteStripe.strokeWidth = 3
		car.addChild(whiteStripe)

		floor = new Rectangle(p5, new Size(p6.x-p5.x, width))
		floorPath = new Path.Rectangle(floor)

		floorPath.strokeColor = 'black'
		floorPath.strokeWidth = 1
		floorPath.dashArray = [10, 4]

		car.addChild(floorPath)
		car.addChild(createTab(floor.bottomLeft, floor.bottomRight))
		return

	gui.add(global, 'shapeType', global.shapeTypes).onChange(updateShape)
	gui.add(size, 'paperZoom', 0.1, 1).onChange (value)->
		$("#paperCanvas").css(zoom:value)
		return
	gui.add(size, 'tabSize', 0, 20).onChange(updateShape)
	gui.add(size, 'scale', 0, 10).onChange(updateShape)
	gui.add(size, 'width', 0, 200).onChange(updateShape)
	gui.add(size, 'height', 0, 200).onChange(updateShape)
	gui.add(size, 'depth', 0, 200).onChange(updateShape)
	gui.add(size, 'length1', 0, 200).onChange(updateShape)
	gui.add(size, 'length2', 0, 200).onChange(updateShape)
	gui.add(size, 'length3', 0, 200).onChange(updateShape)
	gui.add(size, 'length4', 0, 200).onChange(updateShape)
	gui.add(size, 'length5', 0, 200).onChange(updateShape)
	gui.add(size, 'radius', 0, 200).onChange(updateShape)
	gui.add(global, 'addShape')
	gui.add(global, 'removeShape')

	global.download = ()->
		console.log "clicked: " + global.linkButton.href
		raster = new Raster(view.element)
		result = raster.getSubImage(global.paperRectangle)
		global.linkButton[0].href = result.toDataURL()
		raster.remove()
		global.linkButton[0].download = 'PaperToy.png'
		return

	downloadBtn = gui.add(global, 'download')
	global.linkButton = $('<a>Download</a>')
	global.linkButton.click = (event)->
		# console.log "clicked: " + global.linkButton.href
		# raster = new Raster(view.element)
		# raster.getSubCanvas(global.paperRectangle)
		# global.linkButton[0].href = raster.toDataURL()
		# raster.remove()
		# global.linkButton[0].download = 'PaperToy.png'
		return
	$(downloadBtn.__button).replaceWith(global.linkButton)

	return
)