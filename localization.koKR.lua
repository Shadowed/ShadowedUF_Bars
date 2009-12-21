if( GetLocale() ~= "koKR" ) then
	return
end

SUFBarsLocals = {
	["Color"] = "색상",
	["Use texture"] = "텍스쳐 사용",
	["When enabled it will use a bar texture colored by whatever you set, if you don't enabled this then a solid color is shown with whatever alpha setting you choose."] = "바 텍스쳐 색상을 설정할 때 활성화 할 수 있습니다. 만약, 단색에 알파값을 설정할 수 없을 경우 선택할 수 있습니다.",
	["Empty bar"] = "빈 공간 바",
	["Left -> Right"] = "왼쪽 -> 오른쪽",
	["Right -> Left"] = "오른쪽 -> 왼쪽",
	["Top -> Bottom"] = "위 -> 아래",
	["Bottom -> Top"] = "아래 -> 위",
	["Bar growth"] = "바 진행 방향",
	["Invert colors"] = "색 전환",
	["Inverts the bar color so it's easier to see the deficit."] = "바의 반전 색상을 사용하면, 부족한 상황을 보기 쉬울 수도 있습니다.",
	["How the bar should grow, left -> right means that at 75% it will be 75% away from the right side, at 25% it means it'll be 25% away from the right side."] = "바를 채우는 방식.",
}