extends Control

const basicText = "
	As a new duck rancher there are many responsibilities that you hold, such as making sure your ducks are healthy, and getting enough money to provide for your ducks. It might take you a few tries to fully understand everything going on inside this simulation, so don't feel bad if you fail your first few times ranching as you can always start again. 
	
	To start moving around you can use the 'WASD' keys to fly in a direction. To turn your view, hold down right click and drag. 
	
	If you want to interact with a building to see what's inside, you can click on it and then press 'Spacebar'.
	
	If you want to see how healthy your duck is, you can click on it and it will display the name, how full the duck is, the age of your duck, and how healthy your duck is.
	
	If you want to learn about the systems more intricately, you can click through the other tabs. 
"

const foodText = "
	When you go shopping for your duck's food, there are a few things you should take into consideration, namely how much food, and what food.
	[b][u]How much food should you feed your duck?[/u][/b]
		Some ducks need more food then others as they spend it on being stronger or faster. Just try to find a nice balance where they won't starve and they won't be overfed.
		[u]Keep in mind that when you feed the duck with the same food over and over, the nutritional balance will be off and they won't be much healthier.[/u]
	[b][u]What food should you feed to your duck?[/u][/b]
		Different foods give different buffs to your ducks, and they also fill up your duck with different amounts.
		[b][u]Bread:[/u][/b] will make your duck lose color because of low nutrition.
		[b][u]Peas:[/u][/b] will only fill up your duck.
		[b][u]Nuts:[/u][/b] will make your duck stronger.
		[b][u]Grapes:[/u][/b] will do the opposite of bread and give your duck more color.
		[b][u]Peppers:[/u][/b] will make your duck faster. (Keep in mind that this will make your duck use up more food.)
		[b][u]Watermelon:[/u][/b] will make your duck bigger.
		[b][u]Sunflowers:[/u][/b] will make your duck brighter.
		[b][u]Vaccines:[/u][/b] will cure your duck of a mild cold and make their base healthiness higher.
	
	When you feed your duck good food, your duck will be less likely to get sick as their body is better prepared to fight back against diseases before they spread. 
"

const medicalText = "
	Raising healthy ducks can be hard if you don't know what you are doing. Here are some tips to help you out:
	[b][u]1:[/u][/b] If your duck looks more green that usual, your duck might be sick and should probably be checked out before it starts becoming sad and weak.
	[b][u]2:[/u][/b] If you are struggling to keep your duck's healthiness up, maybe you need to feed your duck a more varied diet, or give it a vaccine or two to boost up its base healthiness.
	[b][u]3:[/u][/b] Watermelon are one of the best food sources to keep a duck healthy because if it starts getting extremely hungry you can quickly feed it a watermelon to fill it up.
	[b][u]4:[/u][/b] Don't let your duck's healthiness go down, the medical bills might make you go into debt.
	[b][u]5:[/u][/b] An unhealthy duck might make the duck's children more likely to get sick, so make sure to get your ducks checked before breeding.
	[b][u]6:[/u][/b] Don't leave your duck sick for too long as the speed in which it becomes hungry will increase drastically, and it will eventually become weak.
	
	Remember that your duck will not get better if it is more than mildly sick. It must get a check up from the hospital first and then you need to wait for it to get better. 
"
const miningText = "
	When you decide that you need to make money to provide for your ducks, you need to prepare one of them for the mines. If you send them there with little strength and very unhealthy, you aren't going to make much money. The first thing you should do is feed your duck some nuts to make it stronger. When your duck is stronger it has the capability to mine more ores on its journey. 
	If you enter your duck into the mines when it isn't very healthy, there is a pretty high chance it will get injured and you will have to pay medical bills.
	[b][u]The minigame:[/u][/b] About every 30s in the mine, three paths will show, click one of the paths and see what reward / punishment you get. Your duck can get injured, it might take longer to get out, or you might get higher mining value to get more ores.
"
const breedingText = "
	Breeding ducks is a lot more simple than you may think. Based on what the two parent ducks stats are, the baby's stats will be somewhere in between. If the parents are both red, more than likely the baby will also be red. 
	
	Getting a baby duck isn't that simple though, as when it grows up you will have to feed it and take care of it like your other ducks and that can be very difficult if your duck loses its hunger quickly. 
	
	Remember to manage your money carefully, and be responsible with what decisions you make to take care of your ducks the best you can.
"

func _on_basics_pressed() -> void:
	$"Body Content".text = basicText
	$Title.text = "Basic Information"

func _on_food_pressed() -> void:
	$"Body Content".text = foodText
	$Title.text = "Food and Nutrition System"

func _on_medical_pressed() -> void:
	$"Body Content".text = medicalText
	$Title.text = "How to Raise Healthy Ducks"

func _on_mining_pressed() -> void:
	$"Body Content".text = miningText
	$Title.text = "Money Making in the Mines"

func _on_breeding_pressed() -> void:
	$"Body Content".text = breedingText
	$Title.text = "Breeding New Ducks"
