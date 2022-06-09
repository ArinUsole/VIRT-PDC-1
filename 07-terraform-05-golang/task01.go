package main

import "fmt"

func main() {
	fmt.Print("Enter a meters: ")
	var meters float64
	fmt.Scanf("%f", &meters)

	toots := meters / 0.3048

	fmt.Println("Foots is ", toots)
}
