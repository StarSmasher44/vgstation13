//**************************************************************
// Map Datum -- Snow Taxi Outpost
//**************************************************************

/datum/map/active
	nameShort = "snaxi"
	nameLong = "Taxi Outpost"
	map_dir = "snowtaxi"
	tDomeX = 127
	tDomeY = 67
	tDomeZ = 2
	zAsteroid = 6
	zDeepSpace = 5
	base_turf = /turf/snow
	zLevels = list(
		/datum/zLevel/station/snow,
		/datum/zLevel/centcomm,
		/datum/zLevel/space/snow{
			name = "abandonedListeningOutpost" ;
			},
		/datum/zLevel/space/snow{
			name = "russianColony" ;
			},
		/datum/zLevel/space/snow{
			name = "tundraCrashedShip" ;
			},
		/datum/zLevel/mining/snow,
		)
	enabled_jobs = list(/datum/job/trader)

/datum/map/active/New()
	.=..()

	research_shuttle.name = "mine cage" //There is only one "shuttle" on taxi - the mine cage
	research_shuttle.disable_mesons = 1 // no mesons for you
	research_shuttle.req_access = list() //It's shared by miners and researchers, so remove access requirements


////////////////////////////////////////////////////////////////
#include "taxioutpost.dmm"