extends Node

signal onPrint(message : String, color : Color)

const defaultColor : Color = Color("ffffff");
const logColor : Color = Color("738aff");
const warningColor : Color = Color("ffd994");
const errorColor : Color = Color("ff738a");
const successColor : Color = Color("73ff8a");

func print( \
	a0 : Variant = null, a1 : Variant = null, a2 : Variant = null, a3 : Variant = null, a4 : Variant = null, \
	a5 : Variant = null, a6 : Variant = null, a7 : Variant = null, a8 : Variant = null, a9 : Variant = null
) -> void:
	printColor(defaultColor, a0, a1, a2, a3, a4, a5, a6, a7, a8, a9);

func log( \
	a0 : Variant = null, a1 : Variant = null, a2 : Variant = null, a3 : Variant = null, a4 : Variant = null, \
	a5 : Variant = null, a6 : Variant = null, a7 : Variant = null, a8 : Variant = null, a9 : Variant = null
) -> void:
	printColor(logColor, a0, a1, a2, a3, a4, a5, a6, a7, a8, a9);
	
func printWarning( \
	a0 : Variant = null, a1 : Variant = null, a2 : Variant = null, a3 : Variant = null, a4 : Variant = null, \
	a5 : Variant = null, a6 : Variant = null, a7 : Variant = null, a8 : Variant = null, a9 : Variant = null
) -> void:
	printRaw(warningColor, a0, a1, a2, a3, a4, a5, a6, a7, a8, a9);
	
func printError( \
	a0 : Variant = null, a1 : Variant = null, a2 : Variant = null, a3 : Variant = null, a4 : Variant = null, \
	a5 : Variant = null, a6 : Variant = null, a7 : Variant = null, a8 : Variant = null, a9 : Variant = null
) -> void:
	printRaw(errorColor, a0, a1, a2, a3, a4, a5, a6, a7, a8, a9);

func printSuccess( \
	a0 : Variant = null, a1 : Variant = null, a2 : Variant = null, a3 : Variant = null, a4 : Variant = null, \
	a5 : Variant = null, a6 : Variant = null, a7 : Variant = null, a8 : Variant = null, a9 : Variant = null
) -> void:
	printRaw(successColor, a0, a1, a2, a3, a4, a5, a6, a7, a8, a9);
	
func printColor( \
	color : Color, \
	a0 : Variant = null, a1 : Variant = null, a2 : Variant = null, a3 : Variant = null, a4 : Variant = null, \
	a5 : Variant = null, a6 : Variant = null, a7 : Variant = null, a8 : Variant = null, a9 : Variant = null
) -> void:
	printRaw(color, a0, a1, a2, a3, a4, a5, a6, a7, a8, a9);

func printRaw( \
	color : Color, \
	a0 : Variant = null, a1 : Variant = null, a2 : Variant = null, a3 : Variant = null, a4 : Variant = null, \
	a5 : Variant = null, a6 : Variant = null, a7 : Variant = null, a8 : Variant = null, a9 : Variant = null
):
	# Collect args into single array.
	var arguments : Array[Variant] = [ 
		a0, a1, a2, a3, a4, a5, a6, a7, a8, a9 
	].filter(func(v : Variant) -> bool: return v != null);
	
	# Convert args to string.
	var message : String = "%s".repeat(arguments.size()).strip_edges() % arguments;
	
	# Send signal.
	onPrint.emit(message, color);
	
	# Print string.
	print(message);
