local tpl, xml=require 'tpl', require 'xml'

-- create the values
local values={}
values.title="An interesting title"

-- load the templates
local templates={}
templates.header=tpl.parse(io.open 'examples/header.xml')
templates.nav=tpl.parse(io.open 'examples/nav.xml')
templates.footer=tpl.parse(io.open 'examples/footer.xml')
templates.article=tpl.parse(io.open 'examples/article.xml')
templates.page=tpl.parse(io.open 'examples/page.html')
values.templates=templates

-- create articles
local articles={}
do
	local a={}
	a.title="Lorem ipsum"
	a.paragraphs={
		"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse pellentesque efficitur metus. Aliquam ac imperdiet dolor. Quisque eget faucibus quam, quis consequat nibh. Nullam felis mauris, tincidunt nec faucibus in, ullamcorper porttitor risus. Suspendisse placerat mollis arcu, ullamcorper vestibulum nibh tincidunt nec. In id ornare est. Suspendisse eu leo magna. Vestibulum malesuada dolor eu dui finibus pulvinar. Nam suscipit eleifend efficitur. Quisque posuere finibus tellus, ut varius odio viverra ac. Cras nisi ex, tempus ut elementum at, tincidunt in nisl. Nullam sed tortor fringilla, luctus felis vel, placerat nunc.",
		"Cras sit amet maximus urna. Sed elementum tincidunt lectus sed scelerisque. Aliquam erat volutpat. In tincidunt vel magna vel aliquam. In sed leo faucibus, lacinia arcu ac, pretium est. Aenean vitae tortor ultricies tortor fermentum interdum vitae quis turpis. In hac habitasse platea dictumst. Cras vitae placerat nibh. Etiam sodales erat in nisl faucibus, et pellentesque odio aliquet. Nullam at condimentum nisi, at lobortis dui. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.",
		"Donec tincidunt nibh sit amet tincidunt semper. Integer fringilla, nisl sed auctor lobortis, sem quam maximus tellus, sit amet pretium leo odio at dolor. Proin nec rutrum felis, eu sagittis neque. Nam sem mi, feugiat blandit laoreet in, sollicitudin sit amet tellus. Aliquam sit amet hendrerit nibh, quis imperdiet tellus. Ut fringilla felis nec nisi euismod luctus. Suspendisse lorem arcu, hendrerit et gravida non, facilisis sit amet lorem. Praesent quis lacus orci. Aenean quis auctor enim, sed consectetur diam. Fusce lacus risus, faucibus in magna at, fermentum tempor lorem. Integer at urna ac velit ultrices faucibus ac in erat. Aenean tincidunt, quam vitae egestas sagittis, quam dolor ultrices leo, accumsan faucibus arcu mi lobortis sem.",
		"Duis consectetur nibh non purus cursus convallis. Duis commodo a ipsum nec porta. Quisque sit amet ante a elit ullamcorper commodo. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Proin sit amet magna faucibus, varius est at, interdum tortor. Curabitur vulputate nec est et cursus. Maecenas at libero eget leo fermentum pulvinar.",
		"Pellentesque aliquet neque vitae libero aliquam tempor. Cras vel libero turpis. Pellentesque quis neque sem. Suspendisse accumsan id est sit amet blandit. Mauris porttitor dictum vulputate. Nulla facilisis risus a leo feugiat, nec malesuada metus imperdiet. Nulla facilisis tellus at ligula tincidunt porta."
	}
	a.author="Unknown"
	a.date="Unknown"
	table.insert(articles, a)
end
values.articles=articles

local fd=io.open('examples/rendered.html', 'w')
fd:write(templates.page:render(values))
