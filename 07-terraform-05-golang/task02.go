package main

import (
	"fmt"
	"math"
)

func main() {
	var mn int = math.MaxInt16
	var x = [...]int{48, 96, 86, 68, 57, 82, 63, 70, 37, 34, 83, 27, 19, 97, 9, 17}
	for _, i := range x {
		if i < mn {
			mn = i
		}
	}
	fmt.Println("MIN element is ", mn)
}
