library(terra)
library(tmap)

dat <- c(rep(0,45),
         0,0,1,0,0,1,0,1,0,0,0,1,0,1,0,0,0,0,1,0,0,1,0,1,0,0,0,1,0,1,0,0,0,0,1,0,0,1,0,1,0,0,0,1,0,
         0,0,0,1,0,0,1,1,0,1,0,1,0,0,1,1,0,0,0,1,0,0,1,1,0,1,0,1,0,0,1,1,0,0,0,1,0,0,1,1,0,1,0,1,0,
         0,1,1,1,0,0,1,0,0,0,1,1,0,1,1,0,0,1,1,1,0,0,1,0,0,0,1,1,0,1,1,0,0,1,1,1,0,0,1,0,0,0,1,1,0,
         rep(0,45))

conway <- rast(matrix(nrow = 5,
                      ncol = 45,
                      data = dat,
                      byrow = TRUE))

##### 
# Static fig
#####

m1 <- tm_shape(conway)+
  tm_raster(legend.show=F,
            palette = c("#faf7f2","#1976d2"))+
  tm_layout(frame = F,outer.margins = F,bg.color = '#faf7f2')

#####
# GIF
#####

gif_dat <- c(rep(0,55),
             0,0,1,0,0, 0,1,0,1,0, 0,0,0,1,0, 0,1,0,0,0, 0,0,1,0,0,  0,1,0,1,0,  0,0,0,1,0, 0,1,0,0,0, 0,0,1,0,0, 0,1,0,1,0,  0,0,0,1,0,
             0,0,0,1,0, 0,0,1,1,0, 0,1,0,1,0, 0,0,1,1,0, 0,0,0,1,0,  0,0,1,1,0,  0,1,0,1,0, 0,0,1,1,0, 0,0,0,1,0, 0,0,1,1,0,  0,1,0,1,0,
             0,1,1,1,0, 0,0,1,0,0, 0,0,1,1,0, 0,1,1,0,0, 0,1,1,1,0,  0,0,1,0,0,  0,0,1,1,0, 0,1,1,0,0, 0,1,1,1,0, 0,0,1,0,0,  0,0,1,1,0,
             rep(0,55))

conway_gif <- rast(matrix(nrow = 5,
                          ncol = 55,
                          data = gif_dat,
                          byrow = TRUE))

conway_gif$gifind = matrix(rep(rep(1:11,
                                   each = 5),
                               each = 5),nrow=5)

m2 <- tm_shape(conway_gif)+
  tm_raster(legend.show=F,
            palette = c("#faf7f2","#1976d2"))+
  tm_layout(frame = F,
            outer.margins = F,
            bg.color = '#faf7f2',
            panel.show = F,main.title = F, 
            panel.labels = F)+
  tm_facets(along = 'gifind')
anim <- tmap_animation(m2,
                       filename=paste0(getwd(),'/images/GOL_gif.gif'),
                       width=75,
                       height=15,
                       dpi=300)

