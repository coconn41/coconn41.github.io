library(sf)
library(dplyr)
library(tmap)
library(tmaptools)
library(leastcostpath)
library(landscapemetrics)
library(raster)
library(terra)
library(FedData)
library(maptiles)

#####
# Download land cover data:
#####
set.seed(1)
tdir <- tempdir()
ZCTAurl <- "https://www2.census.gov/geo/tiger/GENZ2018/shp/cb_2018_us_zcta510_500k.zip"
if(file.exists(paste(tdir,"/cb_2018_us_zcta510_500k.shp", sep = "")) == F){
  download.file(ZCTAurl, destfile = file.path(tdir, "ZCTAs.zip"))
  unzip(file.path(tdir, "ZCTAs.zip"), exdir = tdir)}
ZCTA <- read_sf(paste(tdir,"/cb_2018_us_zcta510_500k.shp",sep = "")) %>%
  filter(ZCTA5CE10 == "14086") %>%
  st_transform(., crs = 32618)

LC <- get_nlcd(template = ZCTA,
               label = "NLCD",
               dataset = 'landcover',
               year = 2019,
               landmass = 'L48',
               force.redo = T,
               extraction.dir = tdir)
LCproj <- project(LC, crs(ZCTA))
LCcrop <- crop(x = LCproj,
               y = vect(ZCTA),
               mask = T)

#####
# Process nodes:
#####
LC_forest_patches = LCcrop
values(LC_forest_patches)[values(LC_forest_patches) == 42] <- 41
values(LC_forest_patches)[values(LC_forest_patches) == 43] <- 41
values(LC_forest_patches)[values(LC_forest_patches) != 41] <- NA

y <- get_patches(LC_forest_patches,directions = 4)
poly <- as.polygons(y$layer_1$class_41)
fin_poly <- st_as_sf(poly) %>%
  st_transform(., crs = st_crs(ZCTA))
nodes <- st_centroid(fin_poly)

select_nodes <- nodes %>%
  filter(lyr.1 %in% c(223, 487)) %>%
  mutate(text = c("A", "B"))
select_polys <- fin_poly %>%
  filter(lyr.1 %in% c(223, 487))
unselect_nodes <- nodes %>%
  filter(!c(lyr.1 %in% c(223, 487)))
unselect_polys <- fin_poly %>%
  filter(!c(lyr.1 %in% c(223, 487)))

#####
# Process resistance raster:
#####

LC_forest <- LCcrop
forest_values <- c(41, 42, 43, 51, 52, 71)
values(LC_forest)[!(values(LC_forest) %in% forest_values)] <- 0
values(LC_forest)[values(LC_forest) %in% forest_values] <- 1

LC_cropland <- LCcrop
cropland_values <- c(81, 82)
values(LC_cropland)[!(values(LC_cropland) %in% cropland_values)] <- 0
values(LC_cropland)[values(LC_cropland) %in% cropland_values] <- 35

LC_wetland <- LCcrop
wetland_values <- c(90, 95)
values(LC_wetland)[!(values(LC_wetland) %in% wetland_values)] <- 0
values(LC_wetland)[values(LC_wetland) %in% wetland_values] <- 100

LC_water <- LCcrop
water_values <- c(11)
values(LC_water)[!(values(LC_water) %in% wetland_values)] <- 0
values(LC_water)[values(LC_water) %in% wetland_values] <- 1000

LC_high_developed <- LCcrop
high_developed_values <- c(24)
values(LC_high_developed)[!(values(LC_high_developed) %in% high_developed_values)] <- 0
values(LC_high_developed)[values(LC_high_developed) %in% high_developed_values] <- 1000

LC_med_developed <- LCcrop
med_developed_values <- c(23)
values(LC_med_developed)[!(values(LC_med_developed) %in% med_developed_values)] <- 0
values(LC_med_developed)[values(LC_med_developed) %in% med_developed_values] <- 100

LC_low_developed <- LCcrop
low_developed_values <- c(21, 22)
values(LC_low_developed)[!(values(LC_low_developed) %in% low_developed_values)] <- 0
values(LC_low_developed)[values(LC_low_developed) %in% low_developed_values] <- 27

Resistance_grid <- sum(LC_forest,
                       LC_cropland,
                       na.rm = T)
Resistance_grid <- sum(Resistance_grid,
                       LC_wetland,
                       na.rm = T)
Resistance_grid <- sum(Resistance_grid,
                       LC_water,
                       na.rm = T)
Resistance_grid <- sum(Resistance_grid,
                       LC_high_developed,
                       na.rm = T)
Resistance_grid <- sum(Resistance_grid,
                       LC_med_developed,
                       na.rm = T)
Resistance_grid <- sum(Resistance_grid,
                       LC_low_developed,
                       na.rm = T)

Resistance_grid[Resistance_grid == 0] <- NA
Resistance_grid <- 1 / Resistance_grid
Rgrid <- raster(Resistance_grid)


bbdf <- st_bbox(select_nodes) %>%
  bb_poly(.) %>% 
  st_as_sf() %>%
  st_buffer(., dist = 100) 

tr1 <- create_cs(crop(x = rast(Rgrid),
                      y = bbdf,
                      mask = T))

lcp <- create_lcp(x = tr1,
                  origin = select_nodes[1,],
                  destination = select_nodes[2,]) %>%
  st_as_sf() 

tiles <- get_tiles(x = lcp,
                   provider = "CartoDB.PositronNoLabels")
m1 <- tm_shape(tiles,bbox = st_bbox(bbdf))+
  tm_rgb(legend.show = F)+
  # tm_shape(unselect_polys)+
  # tm_polygons(col = 'green',
  #             alpha = .2)+
  tm_shape(select_polys)+
  tm_polygons(col = 'green')+
  tm_shape(lcp)+
  tm_lines(col = 'black',
           lwd = 2.5)+
  tm_shape(lcp)+
  tm_lines(col = 'purple',
           lwd = 2)+
  tm_shape(select_nodes)+
  tm_dots(size = .5,
          col = 'black')+
  tm_shape(select_nodes)+
  tm_dots(size = .35,
          col = 'purple')+
  tm_shape(select_nodes)+
  tm_text(text = 'text',
          ymod=.6,
          size=.6)
tmap_save(m1,
          filename = paste0(getwd(), "/images/Masthead_map.jpg"),
          width = 7.5,
          outer.margins = F)
