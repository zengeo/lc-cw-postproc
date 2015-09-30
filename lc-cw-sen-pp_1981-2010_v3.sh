#!/bin/sh
#
#-----------------
# 30.9.2015.
# Perform post-processing of land cover and cross walking sensitivity experiments conducted with
# JSBACH, JULES and ORCHIDEE land surface schemes in the frame of ESA-CCI-LC project
# Goran Georgievski
# 
# LSM - land surface model, allowed value so far is JSBACH
# plans are to implement ORCHIDEE and JULES 

LSM=JSBACH  

case "$LSM" in
 "JSBACH")
# root directory for cross-walking sensitivity experiments are in 
# /scratch/mpi/mpiles/thy/m300348/jsbach_expmean/LC-CW-sensitivity/
# experiment abbreviations are
# MPI reference run with MPI PFTS
# ESA reference run with ESA PFT
# MIN minLC refCW
# MAX maxLC refCW
# MI2 minLC minCW
# MA2 maxLC maxCW

 exproot=LC-CW-sensitivity
 for exper in MA2 MAX ESA MIN MI2 MPI; do 
 indir=/scratch/mpi/mpiles/thy/m300348/jsbach_expmean/"${exproot}"/"${exper}"/                      # input directory with monthly means  
 outdir=/scratch/mpi/mpiles/thy/m300348/jsbach_expmean/"${exproot}"/"${exper}"/stat/                # directory for annual and seasonal means
 temp_dir=/scratch/mpi/mpiles/thy/m300348/jsbach_expmean/"${exproot}"/"${exper}"/cdo_temp/          # temporary directory  

 mkdir -p "${outdir}"
 mkdir -p "${temp_dir}"

 cd "${indir}"
 echo "${indir}"
 mv mon_"${exper}"_jsbach_1979.tar mon_"${exper}"_jsbach_1980.tar "${temp_dir}"                           # move the files not needed for analysis into the temporary directory
## untar if needed
# for yy in {1981..2010}; do             
# echo "${yy}"
# tar -xvf mon_"${exper}"_jsbach_"${yy}".tar "${exper}"_jsbach_land_mm_"${yy}".nc "${exper}"_jsbach_veg_mm_"${yy}".nc      
# done
##

y_0=1981
y_n=2010

# standard variables

#ncrcat -v albedo "$exper"_jsbach_land_*.nc "$outdir"albedo_"$exper"_jsbach_"$y_0"_"$y_n".nc
#ncrcat -v surface_temperature "$exper"_jsbach_land_*.nc "$outdir"stemp_"$exper"_jsbach_"$y_0"_"$y_n".nc
#ncrcat -v sensible_heat_flx "$exper"_jsbach_land_*.nc "$outdir"sensh_"$exper"_jsbach_"$y_0"_"$y_n".nc
#ncrcat -v evapotranspiration "$exper"_jsbach_land_*.nc "$outdir"evap_"$exper"_jsbach_"$y_0"_"$y_n".nc   # evapo
#ncrcat -v soil_moisture "$exper"_jsbach_land_*.nc "$outdir"soilm_"$exper"_jsbach_"$y_0"_"$y_n".nc
ncrcat -v box_GPP_yDayMean "$exper"_jsbach_veg_*.nc "$outdir"tmp_gpp_"$exper"_jsbach_"$y_0"_"$y_n".nc                   # Mean GPP Rate of the Previous Day (173)  
ncrcat -v box_NPP_yDayMean "$exper"_jsbach_veg_*.nc "$outdir"tmp_npp_"$exper"_jsbach_"$y_0"_"$y_n".nc
ncrcat -v box_soil_respiration "$exper"_jsbach_veg_*.nc "$outdir"tmp_soil_respiration_"$exper"_jsbach_"$y_0"_"$y_n".nc
#ncrcat -v boxC_green "$exper"_jsbach_veg_*.nc "$outdir"tmp_boxC_green_"$exper"_jsbach_"$y_0"_"$y_n".nc
#ncrcat -v boxC_woods "$exper"_jsbach_veg_*.nc "$outdir"tmp_boxC_woods_"$exper"_jsbach_"$y_0"_"$y_n".nc
#ncrcat -v boxC_reserve "$exper"_jsbach_veg_*.nc "$outdir"tmp_boxC_reserve_"$exper"_jsbach_"$y_0"_"$y_n".nc

# some extras

#ncrcat -v snow "$exper"_jsbach_land_*.nc "$outdir"snow_"$exper"_jsbach_"$y_0"_"$y_n".nc
#ncrcat -v runoff "$exper"_jsbach_land_*.nc "$outdir"runoff_"$exper"_jsbach_"$y_0"_"$y_n".nc
#ncrcat -v latent_heat_flx "$exper"_jsbach_land_*.nc "$outdir"lath_"$exper"_jsbach_"$y_0"_"$y_n".nc

cd $outdir
echo $outdir

############ this part below is with conversion in Gt/y from previous version
##
##cdo mulc,193293455.8 -vertsum tmp_gpp_"$exper"_jsbach_"$y_0"_"$y_n".nc gpp_"$exper"_jsbach_"$y_0"_"$y_n".nc
##ncatted -a units,box_GPP_yDayMean,o,c,"Gt C/a" gpp_"$exper"_jsbach_"$y_0"_"$y_n".nc
##cdo mulc,193293455.8 -vertsum tmp_npp_"$exper"_jsbach_"$y_0"_"$y_n".nc npp_"$exper"_jsbach_"$y_0"_"$y_n".nc
##ncatted -a units,box_NPP_yDayMean,o,c,"Gt C/a" npp_"$exper"_jsbach_"$y_0"_"$y_n".nc
##cdo mulc,193293455.8 -vertsum tmp_soil_respiration_"$exper"_jsbach_"$y_0"_"$y_n".nc box_soil_respiration_"$exper"_jsbach_"$y_0"_"$y_n".nc
##ncatted -a units,box_soil_respiration,o,c,"Gt C/a" box_soil_respiration_"$exper"_jsbach_"$y_0"_"$y_n".nc
##cdo add npp_"$exper"_jsbach_"$y_0"_"$y_n".nc box_soil_respiration_"$exper"_jsbach_"$y_0"_"$y_n".nc nee_"$exper"_jsbach_"$y_0"_"$y_n".nc
##ncrename -v box_NPP_yDayMean,box_NEE_yDayMean  nee_"$exper"_jsbach_"$y_0"_"$y_n".nc
##
########### below is update version with conversion to g/month/m2
#
# units and conversion factors NPP and GPP are given in mol(CO2) m-2(grid box) s-1
# 1 mol CO2 weights 44.0095 g CO2
# 1 mol C weights 12.0107 g C
# so 1 mol CO2 weights 0.2729115 mol C
# therefore in 1 mol CO2 C weights 3.2778587 g
# 1/s = nr of days per month * 24 * 3600/month  
#

cdo mulc,283207 -vertsum tmp_gpp_"$exper"_jsbach_"$y_0"_"$y_n".nc tmp2_gpp_"$exper"_jsbach_"$y_0"_"$y_n".nc
cdo muldpm tmp2_gpp_"$exper"_jsbach_"$y_0"_"$y_n".nc gpp_u2_"$exper"_jsbach_"$y_0"_"$y_n".nc
ncatted -a units,box_GPP_yDayMean,o,c,"g C m-2 month-1" gpp_u2_"$exper"_jsbach_"$y_0"_"$y_n".nc
cdo mulc,283207 -vertsum tmp_npp_"$exper"_jsbach_"$y_0"_"$y_n".nc tmp2_npp_"$exper"_jsbach_"$y_0"_"$y_n".nc
cdo muldpm tmp2_npp_"$exper"_jsbach_"$y_0"_"$y_n".nc npp_u2_"$exper"_jsbach_"$y_0"_"$y_n".nc
ncatted -a units,box_NPP_yDayMean,o,c,"g C m-2 month-1" npp_u2_"$exper"_jsbach_"$y_0"_"$y_n".nc
cdo mulc,1037724.5 -vertsum tmp_soil_respiration_"$exper"_jsbach_"$y_0"_"$y_n".nc tmp2_box_soil_respiration_"$exper"_jsbach_"$y_0"_"$y_n".nc
cdo muldpm tmp2_box_soil_respiration_"$exper"_jsbach_"$y_0"_"$y_n".nc box_soil_respiration_u2_"$exper"_jsbach_"$y_0"_"$y_n".nc
ncatted -a units,box_soil_respiration,o,c,"g C m-2 month-1" box_soil_respiration_u2_"$exper"_jsbach_"$y_0"_"$y_n".nc
cdo add npp_u2_"$exper"_jsbach_"$y_0"_"$y_n".nc box_soil_respiration_u2_"$exper"_jsbach_"$y_0"_"$y_n".nc nee_u2_"$exper"_jsbach_"$y_0"_"$y_n".nc
ncrename -v box_NPP_yDayMean,box_NEE_yDayMean nee_u2_"$exper"_jsbach_"$y_0"_"$y_n".nc
#ncrename -v boxC_green,AboBm tmp_boxC_green_"$exper"_jsbach_"$y_0"_"$y_n".nc
#ncrename -v boxC_woods,AboBm tmp_boxC_woods_"$exper"_jsbach_"$y_0"_"$y_n".nc
#ncrename -v boxC_reserve,AboBm tmp_boxC_reserve_"$exper"_jsbach_"$y_0"_"$y_n".nc
#cdo add tmp_boxC_green_"$exper"_jsbach_"$y_0"_"$y_n".nc tmp_boxC_woods_"$exper"_jsbach_"$y_0"_"$y_n".nc tmp_AboBm_"$exper"_jsbach_"$y_0"_"$y_n".nc
#cdo add tmp_boxC_reserve_"$exper"_jsbach_"$y_0"_"$y_n".nc tmp_AboBm_"$exper"_jsbach_"$y_0"_"$y_n".nc tmp2_AboBm_"$exper"_jsbach_"$y_0"_"$y_n".nc
#cdo mulc,0.01201070 -vertsum tmp2_AboBm_"$exper"_jsbach_"$y_0"_"$y_n".nc AboBm_"$exper"_jsbach_"$y_0"_"$y_n".nc
#ncatted -a units,AboBm,o,c,"kg C m-2" AboBm_"$exper"_jsbach_"$y_0"_"$y_n".nc

# calculate means of the period 2000-2009
# monthly means (average anual cycle)

#cdo monmean albedo_"$exper"_jsbach_"$y_0"_"$y_n".nc "$outdir"monmean_albedo_"$exper"_jsbach_"$y_0"_"$y_n".nc
#cdo monmean stemp_"$exper"_jsbach_"$y_0"_"$y_n".nc "$outdir"monmean_stemp_"$exper"_jsbach_"$y_0"_"$y_n".nc
#cdo monmean sensh_"$exper"_jsbach_"$y_0"_"$y_n".nc "$outdir"monmean_sensh_"$exper"_jsbach_"$y_0"_"$y_n".nc
#cdo monmean evap_"$exper"_jsbach_"$y_0"_"$y_n".nc "$outdir"monmean_evap_"$exper"_jsbach_"$y_0"_"$y_n".nc
cdo monmean gpp_u2_"$exper"_jsbach_"$y_0"_"$y_n".nc "$outdir"monmean_gpp_u2_"$exper"_jsbach_"$y_0"_"$y_n".nc
cdo monmean npp_u2_"$exper"_jsbach_"$y_0"_"$y_n".nc "$outdir"monmean_npp_u2_"$exper"_jsbach_"$y_0"_"$y_n".nc
cdo monmean box_soil_respiration_u2_"$exper"_jsbach_"$y_0"_"$y_n".nc "$outdir"monmean_box_soil_respiration_u2_"$exper"_jsbach_"$y_0"_"$y_n".nc
cdo monmean nee_u2_"$exper"_jsbach_"$y_0"_"$y_n".nc "$outdir"monmean_nee_u2_"$exper"_jsbach_"$y_0"_"$y_n".nc
#cdo monmean AboBm_"$exper"_jsbach_"$y_0"_"$y_n".nc "$outdir"monmean_AboBm_"$exper"_jsbach_"$y_0"_"$y_n".nc

#cdo monmean soilm_"$exper"_jsbach_"$y_0"_"$y_n".nc "$outdir"monmean_soilm_"$exper"_jsbach_"$y_0"_"$y_n".nc
#cdo monmean snow_"$exper"_jsbach_"$y_0"_"$y_n".nc "$outdir"monmean_snow_"$exper"_jsbach_"$y_0"_"$y_n".nc
#cdo monmean runoff_"$exper"_jsbach_"$y_0"_"$y_n".nc "$outdir"monmean_runoff_"$exper"_jsbach_"$y_0"_"$y_n".nc
#cdo monmean lath_"$exper"_jsbach_"$y_0"_"$y_n".nc "$outdir"monmean_lath_"$exper"_jsbach_"$y_0"_"$y_n".nc

# seasonal means

#cdo yseasmean albedo_"$exper"_jsbach_"$y_0"_"$y_n".nc "$outdir"yseasmean_albedo_"$exper"_jsbach_"$y_0"_"$y_n".nc
#cdo yseasmean stemp_"$exper"_jsbach_"$y_0"_"$y_n".nc "$outdir"yseasmean_stemp_"$exper"_jsbach_"$y_0"_"$y_n".nc
#cdo yseasmean sensh_"$exper"_jsbach_"$y_0"_"$y_n".nc "$outdir"yseasmean_sensh_"$exper"_jsbach_"$y_0"_"$y_n".nc
#cdo yseasmean evap_"$exper"_jsbach_"$y_0"_"$y_n".nc "$outdir"yseasmean_evap_"$exper"_jsbach_"$y_0"_"$y_n".nc
cdo yseasmean gpp_u2_"$exper"_jsbach_"$y_0"_"$y_n".nc "$outdir"yseasmean_gpp_u2_"$exper"_jsbach_"$y_0"_"$y_n".nc
cdo yseasmean npp_u2_"$exper"_jsbach_"$y_0"_"$y_n".nc "$outdir"yseasmean_npp_u2_"$exper"_jsbach_"$y_0"_"$y_n".nc
cdo yseasmean nee_u2_"$exper"_jsbach_"$y_0"_"$y_n".nc "$outdir"yseasmean_nee_u2_"$exper"_jsbach_"$y_0"_"$y_n".nc
#cdo yseasmean AboBm_"$exper"_jsbach_"$y_0"_"$y_n".nc "$outdir"yseasmean_AboBm_"$exper"_jsbach_"$y_0"_"$y_n".nc

#cdo yseasmean soilm_"$exper"_jsbach_"$y_0"_"$y_n".nc "$outdir"yseasmean_soilm_"$exper"_jsbach_"$y_0"_"$y_n".nc
#cdo yseasmean snow_"$exper"_jsbach_"$y_0"_"$y_n".nc "$outdir"yseasmean_snow_"$exper"_jsbach_"$y_0"_"$y_n".nc
#cdo yseasmean runoff_"$exper"_jsbach_"$y_0"_"$y_n".nc "$outdir"yseasmean_runoff_"$exper"_jsbach_"$y_0"_"$y_n".nc
#cdo yseasmean lath_"$exper"_jsbach_"$y_0"_"$y_n".nc "$outdir"yseasmean_lath_"$exper"_jsbach_"$y_0"_"$y_n".nc

# calculate yearly mean

#cdo timmean monmean_albedo_"$exper"_jsbach_"$y_0"_"$y_n".nc "$outdir"ymean_albedo_"$exper"_jsbach_"$y_0"_"$y_n".nc
#cdo timmean monmean_stemp_"$exper"_jsbach_"$y_0"_"$y_n".nc "$outdir"ymean_stemp_"$exper"_jsbach_"$y_0"_"$y_n".nc
#cdo timmean monmean_sensh_"$exper"_jsbach_"$y_0"_"$y_n".nc "$outdir"ymean_sensh_"$exper"_jsbach_"$y_0"_"$y_n".nc
#cdo timmean monmean_evap_"$exper"_jsbach_"$y_0"_"$y_n".nc "$outdir"ymean_evap_"$exper"_jsbach_"$y_0"_"$y_n".nc
cdo timmean monmean_gpp_u2_"$exper"_jsbach_"$y_0"_"$y_n".nc "$outdir"ymean_gpp_u2_"$exper"_jsbach_"$y_0"_"$y_n".nc
cdo timmean monmean_npp_u2_"$exper"_jsbach_"$y_0"_"$y_n".nc "$outdir"ymean_npp_u2_"$exper"_jsbach_"$y_0"_"$y_n".nc
cdo timmean monmean_nee_u2_"$exper"_jsbach_"$y_0"_"$y_n".nc "$outdir"ymean_nee_u2_"$exper"_jsbach_"$y_0"_"$y_n".nc
#cdo timmean AboBm_"$exper"_jsbach_"$y_0"_"$y_n".nc "$outdir"ymean_AboBm_"$exper"_jsbach_"$y_0"_"$y_n".nc

#cdo timmean monmean_soilm_"$exper"_jsbach_"$y_0"_"$y_n".nc "$outdir"ymean_soilm_"$exper"_jsbach_"$y_0"_"$y_n".nc
#cdo timmean monmean_snow_"$exper"_jsbach_"$y_0"_"$y_n".nc "$outdir"ymean_snow_"$exper"_jsbach_"$y_0"_"$y_n".nc
#cdo timmean monmean_runoff_"$exper"_jsbach_"$y_0"_"$y_n".nc "$outdir"ymean_runoff_"$exper"_jsbach_"$y_0"_"$y_n".nc
#cdo timmean monmean_lath_"$exper"_jsbach_"$y_0"_"$y_n".nc "$outdir"ymean_lath_"$exper"_jsbach_"$y_0"_"$y_n".nc


rm -rf tmp*.nc

done 

exit
