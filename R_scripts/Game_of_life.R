library(terra)
library(tmap)

dat <- c(rep(0,17),
        0,0,1,0,0,1,0,1,0,0,0,1,0,1,0,0,0,
        0,0,0,1,0,0,1,1,0,1,0,1,0,0,1,1,0,
        0,1,1,1,0,0,1,0,0,0,1,1,0,1,1,0,0,
        rep(0,17))

conway <- rast(matrix(nrow = 5,
                 ncol = 17,
                 data = dat,
                 byrow = TRUE))

m1 <- tm_shape(conway)+
  tm_raster(legend.show=F,
            palette = c("#faf7f2","#1976d2"))+
  tm_layout(frame = F,outer.margins = F,bg.color = '#faf7f2')
tmap_save(m1,
          filename=paste0(getwd(),'/images/GOL.jpeg'),
          width=7.5,
          height=1.5,
          dpi=300)

