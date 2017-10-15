
	fn 	ordonner_Points 		_id_pts	 =(
			--#(2, 3, 4, 1), #(3, 4, 1, 2), #(4, 1, 2, 3)
			local min 		=	amin _id_pts
			local id_min 	= finditem _id_pts min
			local tab_debut = #()
			local tab_result = #()
			for i = id_min to  _id_pts.count	 do (
				append tab_debut _id_pts[i]
			)
			for i = id_min to  _id_pts.count	 do 
				deleteItem _id_pts id_min
			tab_result = tab_debut + _id_pts
			tab_result
		)
		
fn boucler 	_array	_id_item 		=(
	
	
	if _id_item >	_array.count do _id_item = mod _id_item 	_array.count
	if _id_item < 1 do _id_item += _array.count
	_id_item as integer
)

fn unir 	_listeTraces =(
	
	local traces = for trace in _listeTraces collect trace
	
-- 	local continu = true
	
	while traces.count > 1 do (
		local result 	= #()
		local trace1 	= traces[1]
		local trace2 	= traces[2]
		format "trace1 : %	" trace1
		format "trace2 : %\n" trace2
		
		
		local ptsCommuns			= #()
		local ptsCommuns_trouve = false
		local idCommun_rect1 		= 0
		
		for i = 1 to  trace1.count  where not  ptsCommuns_trouve   do (
			local id1 = trace1[i]
			local id2 =	finditem 	trace2	 id1
			append result id1
			if  id2 != 0 then (
				format "	-> id2 : %\n" id2
				append ptsCommuns id1
				if ptsCommuns.count == 2 do 
					ptsCommuns_trouve = true
			)
		)
		
		local idPt1_communTrace2 = findItem	trace2  ptsCommuns[1]
		local idPt2_communTrace2 = boucler	trace2  ( idPt1_communTrace2 + 1 )
		
		if trace2[ idPt2_communTrace2 ] != ptsCommuns[2] then (
			local id_Pt1_trace2 = boucler trace2 (idPt1_communTrace2 + 1)
			local id_Pt2_trace2 = boucler trace2 (idPt1_communTrace2 + 2)
			
			local idPt1_communTrace1 = findItem	trace1  ptsCommuns[1]
			local idPt2_communTrace1 = boucler trace1 ( idPt1_communTrace1 + 1 )
			if trace1[ idPt2_communTrace1 ] != ptsCommuns[2] then (
				local idPt2_communTrace1 = boucler trace1		( (finditem trace1  ptsCommuns[2] ) + 1 )
				insertItem   trace2[  id_Pt2_trace2 ]	trace1	 idPt2_communTrace1
				insertItem   trace2[  id_Pt1_trace2 ]	trace1	 idPt2_communTrace1
				
			) else (
				local idPt2_communTrace1 = boucler trace1		( (finditem trace1  ptsCommuns[1] ) + 1 )
				insertItem   trace2[  id_Pt2_trace2 ]	trace1	 idPt2_communTrace1
				insertItem   trace2[  id_Pt1_trace2 ]	trace1	 idPt2_communTrace1
			)
			
			
			
		) else (
			local id_Pt1_trace2 = boucler trace2 (idPt2_communTrace2 +1)
			local id_Pt2_trace2 = boucler trace2 (idPt2_communTrace2 +2)
			format "		-> - B - on insert a partir de %\n" trace2[ id_Pt1_trace2 ]
			
			local idPt1_communTrace1 = findItem	trace1  ptsCommuns[1]
			local idPt2_communTrace1 = boucler trace1 ( idPt1_communTrace1 + 1 )
			if trace1[ idPt2_communTrace1 ] != ptsCommuns[2] then (
				local idPt2_communTrace1 = boucler trace1		( (finditem trace1  ptsCommuns[2] ) + 1 )
				insertItem   trace2[  id_Pt2_trace2 ]	trace1	 idPt2_communTrace1
				insertItem   trace2[  id_Pt1_trace2 ]	trace1	 idPt2_communTrace1
				
			) else (
				local idPt2_communTrace1 = boucler trace1		( (finditem trace1  ptsCommuns[1] ) + 1 )
				insertItem   trace2[  id_Pt2_trace2 ]	trace1	 idPt2_communTrace1
				insertItem   trace2[  id_Pt1_trace2 ]	trace1	 idPt2_communTrace1
			)
			
				
		)
		
		traces[1] = ordonner_Points trace1
		deleteItem  traces 2
		format "traces : %\n" traces
		
	)
	
	
	
/* 	local ptsCommuns_trouve = false
	local idCommun_rect1 = 0
	
	--- on cherche  pt commun 1 -------
	local ptsCommuns =#()
	for i = 1 to  _rect1.count  where not  ptsCommuns_trouve  do (
		local id1 = _rect1[i]
		local id2 =	finditem 	_rect2	 id1
		append result id1
		if  id2 != 0 then (
-- 			append ptsCommuns id1
			
			ptsCommuns_trouve = true
			idCommun_rect1 = i
			local id_pt1 = boucler  _rect2  (  id2 + 1 )
			local id_pt2 = boucler  _rect2  (  id2 + 2 )
			append result 	_rect2[ id_pt1 ]
			append result 	_rect2[ id_pt2 ] 
		)  
	)
	format "ptsCommuns : %\n" ptsCommuns
	for i = idCommun_rect1 + 1 to _rect1.count  do (
		append result 	_rect1[i]
	)
	
	result
	 */
)


clearListener ()
rect1 = #(1, 4, 7, 8)
rect3 =  #(4, 5, 6, 7)
rect2 = #(1, 8, 9, 10)


rects = #(rect1, rect2, rect3)

rect4 =  #(1, 2, 3, 4)

-- #(1, 4, 5, 6, 7, 8, 9, 10)



unir  rects






















