extends Control

var mineralDictionaryPrice = {
	Iron = 20,
	Coal = 10,
	Gold = 100,
	Emerald = 200,
	Diamond = 500,
	Silver = 70,
	Ruby = 250,
	Copper = 50,
	Quartz = 90,
	Amethyst = 350
}

func _ready():
	$Money.text = "$" + str(saveDataValues.money).pad_decimals(0)

func _on_buy_list_item_clicked(index: int, _at_position: Vector2, mouse_button_index: int) -> void:
	"""
	If shop item gets clicked, get the item name and price from the string and check if enough money to buy item, 
	if can buy item, add item to save data, and subtract price from money.
	Updates spent dictionary to add the money spend on the item clicked. 
	"""
	
	var itemPrice = $StoreTab/Buy/BuyList.get_item_text(index)
	
	if mouse_button_index == MOUSE_BUTTON_LEFT && saveDataValues.money - itemPrice.to_int() >= 0: #Left click shop
		var boughtItem = $StoreTab/Buy/BuyList.get_item_text(index).remove_chars(" $0123456789")
		
		$BoughtItem.play()
		$"StoreTab/Buy/Buy Animation".stop()
		$"StoreTab/Buy/Buy Animation".play("slideIn")
		$"StoreTab/Buy/Bought Item Price".text = "-" + str(itemPrice.to_int())
		
		if saveDataValues.foodItems.get(boughtItem) != null:
			saveDataValues.foodItems.set(boughtItem,saveDataValues.foodItems.get(boughtItem) + 1)
		else:
			saveDataValues.foodItems.set(boughtItem,1)
		saveDataValues.money -= itemPrice.to_int()

		if saveDataValues.spentDictionary.get(boughtItem) != null:
			saveDataValues.spentDictionary.set(boughtItem, saveDataValues.spentDictionary.get(boughtItem) - itemPrice.to_int())
		else:
			saveDataValues.spentDictionary.set(boughtItem, -itemPrice.to_int())
	
	$Money.text = "$" + str(saveDataValues.money).pad_decimals(0)

func setUpSellTab():
	$StoreTab/Sell/SellList.clear()
	for m in saveDataValues.miningValues:
		print(m)
		if m != "MiningTime" && m != "duckMiningStartTime" && m != "selectedDuck" && m != "MiningValue" && saveDataValues.miningValues.get(m) != 0 && m !="miniGameStartTimer":
			$StoreTab/Sell/SellList.add_item("$" + str(mineralDictionaryPrice.get(m)) + "  " + m + " " + str(saveDataValues.miningValues.get(m)) + "x")
	$Money.text = "$" + str(saveDataValues.money).pad_decimals(0)
	
func _on_store_tab_tab_selected(tab: int) -> void:
	if tab == 1:
		print("sell Tab opened")
		setUpSellTab()


func _on_sell_list_item_clicked(index: int, _at_position: Vector2, _mouse_button_index: int) -> void:
	var mineral = $StoreTab/Sell/SellList.get_item_text(index).remove_chars(" :.1234567890$x")
	print(mineral + " sold.")
	saveDataValues.miningValues.set(mineral, saveDataValues.miningValues.get(mineral) - 1)
	saveDataValues.money += mineralDictionaryPrice.get(mineral)
	
	if saveDataValues.spentDictionary.get(mineral) != null:
		saveDataValues.spentDictionary.set(mineral, saveDataValues.spentDictionary.get(mineral) + mineralDictionaryPrice.get(mineral))
	else:
		saveDataValues.spentDictionary.set(mineral, mineralDictionaryPrice.get(mineral))
	
	setUpSellTab()


func _on_sell_all_pressed() -> void:
	for m in saveDataValues.miningValues:
		if m == "MiningTime":
			pass
		elif m == "duckMiningStartTime":
			pass
		elif m =="miniGameStartTimer":
			pass
		elif m == "selectedDuck":
			pass
		elif m == "MiningValue":
			pass
		else:
			if saveDataValues.miningValues.get(m) != 0:
				saveDataValues.money += mineralDictionaryPrice.get(m) * saveDataValues.miningValues.get(m)
				if saveDataValues.spentDictionary.get(m) != null:
					saveDataValues.spentDictionary.set(m, saveDataValues.spentDictionary.get(m) + mineralDictionaryPrice.get(m))
				else:
					saveDataValues.spentDictionary.set(m, mineralDictionaryPrice.get(m))
				saveDataValues.miningValues.set(m, 0)
	setUpSellTab()
	
