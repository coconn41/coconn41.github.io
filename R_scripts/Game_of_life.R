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
            palette = c('#1976d2','#f0fff0'))+
  tm_layout(frame = F)
tmap_save(m1,
          filename=paste0(getwd(),'/images/GOL.jpeg'),
          width=7.5,
          height=3,
          dpi=300)

