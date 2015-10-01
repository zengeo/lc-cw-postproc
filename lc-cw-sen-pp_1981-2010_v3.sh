#!/bin/sh
#
#-----------------
# # Perform post-processing of land cover and cross walking sensitivity exp_iniments conducted with
# JSBACH, JULES and ORCHIDEE land surface schemes in the frame of ESA-CCI-LC project
# 30.9.2015. contact: Goran Georgievski (goran.georgievski@mpimet.mpg.de) 
# 
# LSM - land surface model, allowed value so far is JSBACH
# plans are to implement ORCHIDEE and JULES 

 LSM=JSBACH  
#
# case "$LSM" in
# "JSBACH")
 
# root directory for cross-walking sensitivity exp_iniments are in 
# /scratch/mpi/mpiles/thy/m300348/jsbach_expmean/LC-CW-sensitivity/
# exp_iniment abbreviations are
# MPI reference run with MPI PFTS
# ESA reference run with ESA PFT
# MIN minLC refCW
# MAX maxLC refCW
# MI2 minLC minCW
# MA2 maxLC maxCW

 exproot=LC-CW-sensitivity
 for exp_in in MA2 MAX ESA MIN MI2 MPI; do
 
 case "$exp_in" in
   "MPI") exp_out=CTL 
   ;;
   "ESA") exp_out=refLC_refCW 
   ;;
   "MA2") exp_out=maxLC_maxCW 
   ;;
   "MAX") exp_out=maxLC_refCW 
   ;;
   "MIN") exp_out=minLC_refCW 
   ;;
   "MI2") exp_out=minLC_minCW 
   ;;
esac 

 indir=/scratch/mpi/mpiles/thy/m300348/jsbach_expmean/"${exproot}"/"${exp_in}"/                      # input directory with monthly means  
 outdir=/scratch/mpi/mpiles/thy/m300348/jsbach_expmean/"${exproot}"/exchange_release/                # directory for annual and seasonal means
 temp_dir=/scratch/mpi/mpiles/thy/m300348/jsbach_expmean/"${exproot}"/"${exp_in}"/cdo_temp/          # temporary directory  

 mkdir -p "${outdir}"
 mkdir -p "${temp_dir}"

 cd "${indir}"
 echo "${indir}"
 mv mon_"${exp_in}"_jsbach_1979.tar mon_"${exp_in}"_jsbach_1980.tar "${temp_dir}"                           # move the files not needed for analysis into the temporary directory
## untar if needed
# for yy in {1981..2010}; do             
# echo "${yy}"
# tar -xvf mon_"${exp_in}"_jsbach_"${yy}".tar "${exp_in}"_jsbach_land_mm_"${yy}".nc "${exp_in}"_jsbach_veg_mm_"${yy}".nc      
# done
##

y_0=1981
y_n=2010

# concatenate variables for analysis

 ncrcat -v albedo "$exp_in"_jsbach_land_*.nc "$outdir""$LSM"_Albedo_"$exp_out"_"$y_0"_"$y_n".nc
 ncrcat -v surface_temperature "$exp_in"_jsbach_land_*.nc "$outdir""$LSM"_LST_"$exp_out"_"$y_0"_"$y_n".nc
 ncrcat -v sensible_heat_flx "$exp_in"_jsbach_land_*.nc "$outdir""$LSM"_SH_"$exp_out"_"$y_0"_"$y_n".nc
 ncrcat -v evapotranspiration "$exp_in"_jsbach_land_*.nc "$outdir""$LSM"_ET_"$exp_out"_"$y_0"_"$y_n".nc   # evapo
 ncrcat -v soil_moisture "$exp_in"_jsbach_land_*.nc "$outdir""$LSM"_SoilM_"$exp_out"_"$y_0"_"$y_n".nc
 ncrcat -v box_GPP_yDayMean "$exp_in"_jsbach_veg_*.nc "$outdir"tmp_gpp_"$exp_in"_jsbach_"$y_0"_"$y_n".nc                   # Mean GPP Rate of the Previous Day (173)  
 ncrcat -v box_NPP_yDayMean "$exp_in"_jsbach_veg_*.nc "$outdir"tmp_npp_"$exp_in"_jsbach_"$y_0"_"$y_n".nc
 ncrcat -v box_soil_respiration "$exp_in"_jsbach_veg_*.nc "$outdir"tmp_soil_respiration_"$exp_in"_jsbach_"$y_0"_"$y_n".nc
 ncrcat -v boxC_green "$exp_in"_jsbach_veg_*.nc "$outdir"tmp_boxC_green_"$exp_in"_jsbach_"$y_0"_"$y_n".nc
 ncrcat -v boxC_woods "$exp_in"_jsbach_veg_*.nc "$outdir"tmp_boxC_woods_"$exp_in"_jsbach_"$y_0"_"$y_n".nc
 ncrcat -v boxC_reserve "$exp_in"_jsbach_veg_*.nc "$outdir"tmp_boxC_reserve_"$exp_in"_jsbach_"$y_0"_"$y_n".nc

# uncomment if you want some additional variables 
#ncrcat -v snow "$exp_in"_jsbach_land_*.nc "$outdir"snow_"$exp_in"_jsbach_"$y_0"_"$y_n".nc
#ncrcat -v runoff "$exp_in"_jsbach_land_*.nc "$outdir"runoff_"$exp_in"_jsbach_"$y_0"_"$y_n".nc
#ncrcat -v latent_heat_flx "$exp_in"_jsbach_land_*.nc "$outdir"lath_"$exp_in"_jsbach_"$y_0"_"$y_n".nc

cd $outdir
echo $outdir

############ this part below is with conversion in Gt/y from previous version
##
##cdo mulc,193293455.8 -vertsum tmp_gpp_"$exp_in"_jsbach_"$y_0"_"$y_n".nc gpp_"$exp_in"_jsbach_"$y_0"_"$y_n".nc
##ncatted -a units,box_GPP_yDayMean,o,c,"Gt C/a" gpp_"$exp_in"_jsbach_"$y_0"_"$y_n".nc
##cdo mulc,193293455.8 -vertsum tmp_npp_"$exp_in"_jsbach_"$y_0"_"$y_n".nc npp_"$exp_in"_jsbach_"$y_0"_"$y_n".nc
##ncatted -a units,box_NPP_yDayMean,o,c,"Gt C/a" npp_"$exp_in"_jsbach_"$y_0"_"$y_n".nc
##cdo mulc,193293455.8 -vertsum tmp_soil_respiration_"$exp_in"_jsbach_"$y_0"_"$y_n".nc box_soil_respiration_"$exp_in"_jsbach_"$y_0"_"$y_n".nc
##ncatted -a units,box_soil_respiration,o,c,"Gt C/a" box_soil_respiration_"$exp_in"_jsbach_"$y_0"_"$y_n".nc
##cdo add npp_"$exp_in"_jsbach_"$y_0"_"$y_n".nc box_soil_respiration_"$exp_in"_jsbach_"$y_0"_"$y_n".nc nee_"$exp_in"_jsbach_"$y_0"_"$y_n".nc
##ncrename -v box_NPP_yDayMean,box_NEE_yDayMean  nee_"$exp_in"_jsbach_"$y_0"_"$y_n".nc
##
########### below is update version with conversion to g/month/m2
#
# units and conversion factors NPP and GPP are given in mol(CO2) m-2(grid box) s-1; soil respiration is given in mol(C) m-2(grid box) s-1 
# 1 mol CO2 weights 44.0095 g CO2
# 1 mol C weights 12.0107 g C
# so 1 mol CO2 weights 0.2729115 mol C
# therefore in 1 mol CO2 C weights 3.2778587 g
# 1/s = nr of days per month * 24 * 3600  
#

cdo mulc,283207 -vertsum tmp_gpp_"$exp_in"_jsbach_"$y_0"_"$y_n".nc tmp2_gpp_"$exp_in"_jsbach_"$y_0"_"$y_n".nc
cdo muldpm tmp2_gpp_"$exp_in"_jsbach_"$y_0"_"$y_n".nc "$LSM"_GPP_"$exp_out"_"$y_0"_"$y_n".nc
ncatted -a units,box_GPP_yDayMean,o,c,"g C m-2" "$LSM"_GPP_"$exp_out"_"$y_0"_"$y_n".nc
ncrename -v box_GPP_yDayMean,GPP "$LSM"_GPP_"$exp_out"_"$y_0"_"$y_n".nc
cdo mulc,283207 -vertsum tmp_npp_"$exp_in"_jsbach_"$y_0"_"$y_n".nc tmp2_npp_"$exp_in"_jsbach_"$y_0"_"$y_n".nc
cdo muldpm tmp2_npp_"$exp_in"_jsbach_"$y_0"_"$y_n".nc "$LSM"_NPP_"$exp_out"_"$y_0"_"$y_n".nc
ncatted -a units,box_NPP_yDayMean,o,c,"g C m-2" "$LSM"_NPP_"$exp_out"_"$y_0"_"$y_n".nc
ncrename -v box_NPP_yDayMean,NPP "$LSM"_NPP_"$exp_out"_"$y_0"_"$y_n".nc
ncrename -v NPP,NEE "$LSM"_NPP_"$exp_out"_"$y_0"_"$y_n".nc tmp3_npp_"$exp_in"_jsbach_"$y_0"_"$y_n".nc
cdo mulc,1037724.5 -vertsum tmp_soil_respiration_"$exp_in"_jsbach_"$y_0"_"$y_n".nc tmp2_box_soil_respiration_"$exp_in"_jsbach_"$y_0"_"$y_n".nc
cdo muldpm tmp2_box_soil_respiration_"$exp_in"_jsbach_"$y_0"_"$y_n".nc box_soil_respiration_"$exp_in"_jsbach_"$y_0"_"$y_n".nc
ncatted -a units,box_soil_respiration,o,c,"g C m-2" box_soil_respiration_"$exp_in"_jsbach_"$y_0"_"$y_n".nc
ncrename -v box_soil_respiration,NEE box_soil_respiration_"$exp_in"_jsbach_"$y_0"_"$y_n".nc
cdo add tmp3_npp_"$exp_in"_jsbach_"$y_0"_"$y_n".nc box_soil_respiration_"$exp_in"_jsbach_"$y_0"_"$y_n".nc "$LSM"_NEE_"$exp_out"_"$y_0"_"$y_n".nc
ncrename -v boxC_green,AboBm tmp_boxC_green_"$exp_in"_jsbach_"$y_0"_"$y_n".nc
ncrename -v boxC_woods,AboBm tmp_boxC_woods_"$exp_in"_jsbach_"$y_0"_"$y_n".nc
ncrename -v boxC_reserve,AboBm tmp_boxC_reserve_"$exp_in"_jsbach_"$y_0"_"$y_n".nc
cdo add tmp_boxC_green_"$exp_in"_jsbach_"$y_0"_"$y_n".nc tmp_boxC_woods_"$exp_in"_jsbach_"$y_0"_"$y_n".nc tmp_AboBm_"$exp_in"_jsbach_"$y_0"_"$y_n".nc
cdo add tmp_boxC_reserve_"$exp_in"_jsbach_"$y_0"_"$y_n".nc tmp_AboBm_"$exp_in"_jsbach_"$y_0"_"$y_n".nc tmp2_AboBm_"$exp_in"_jsbach_"$y_0"_"$y_n".nc
cdo mulc,12.01070 -vertsum tmp2_AboBm_"$exp_in"_jsbach_"$y_0"_"$y_n".nc "$LSM"_AboBm_"$exp_out"_"$y_0"_"$y_n".nc 
ncatted -a units,AboBm,o,c,"g C m-2" "$LSM"_AboBm_"$exp_out"_"$y_0"_"$y_n".nc

ncrename -v albedo,Albedo "$LSM"_Albedo_"$exp_out"_"$y_0"_"$y_n".nc
ncrename -v surface_temperature,LST "$LSM"_LST_"$exp_out"_"$y_0"_"$y_n".nc  
ncrename -v sensible_heat_flx,SH "$LSM"_SH_"$exp_out"_"$y_0"_"$y_n".nc
ncrename -v evapotranspiration,ET "$LSM"_ET_"$exp_out"_"$y_0"_"$y_n".nc
ncrename -v soil_moisture,SoilM "$LSM"_SoilM_"$exp_out"_"$y_0"_"$y_n".nc

# calculate means of the period 2000-2009
# monthly means (average anual cycle)

cdo ymonmean "$LSM"_Albedo_"$exp_out"_"$y_0"_"$y_n".nc "$LSM"_Albedo_"$exp_out"_Monthly.nc 
cdo ymonmean "$LSM"_LST_"$exp_out"_"$y_0"_"$y_n".nc "$LSM"_LST_"$exp_out"_Monthly.nc   
cdo ymonmean "$LSM"_SH_"$exp_out"_"$y_0"_"$y_n".nc "$LSM"_SH_"$exp_out"_Monthly.nc
cdo ymonmean "$LSM"_ET_"$exp_out"_"$y_0"_"$y_n".nc "$LSM"_ET_"$exp_out"_Monthly.nc
cdo ymonmean "$LSM"_SoilM_"$exp_out"_"$y_0"_"$y_n".nc "$LSM"_SoilM_"$exp_out"_Monthly.nc
cdo ymonmean "$LSM"_NEE_"$exp_out"_"$y_0"_"$y_n".nc "$LSM"_NEE_"$exp_out"_Monthly.nc
cdo ymonmean "$LSM"_GPP_"$exp_out"_"$y_0"_"$y_n".nc "$LSM"_GPP_"$exp_out"_Monthly.nc
cdo ymonmean "$LSM"_AboBm_"$exp_out"_"$y_0"_"$y_n".nc "$LSM"_AboBm_"$exp_out"_Monthly.nc

# seasonal means

cdo yseasmean "$LSM"_Albedo_"$exp_out"_"$y_0"_"$y_n".nc "$LSM"_Albedo_"$exp_out"_Seasonal.nc 
cdo yseasmean "$LSM"_LST_"$exp_out"_"$y_0"_"$y_n".nc "$LSM"_LST_"$exp_out"_Seasonal.nc   
cdo yseasmean "$LSM"_SH_"$exp_out"_"$y_0"_"$y_n".nc "$LSM"_SH_"$exp_out"_Seasonal.nc
cdo yseasmean "$LSM"_ET_"$exp_out"_"$y_0"_"$y_n".nc "$LSM"_ET_"$exp_out"_Seasonal.nc
cdo yseasmean "$LSM"_SoilM_"$exp_out"_"$y_0"_"$y_n".nc "$LSM"_SoilM_"$exp_out"_Seasonal.nc
cdo yseasmean "$LSM"_NEE_"$exp_out"_"$y_0"_"$y_n".nc "$LSM"_NEE_"$exp_out"_Seasonal.nc
cdo yseasmean "$LSM"_GPP_"$exp_out"_"$y_0"_"$y_n".nc "$LSM"_GPP_"$exp_out"_Seasonal.nc
cdo yseasmean "$LSM"_AboBm_"$exp_out"_"$y_0"_"$y_n".nc "$LSM"_AboBm_"$exp_out"_Seasonal.nc

# calculate 30 year time series mean

cdo yearmonmean "$LSM"_Albedo_"$exp_out"_"$y_0"_"$y_n".nc "$LSM"_Albedo_"$exp_out"_Annual.nc 
cdo yearmonmean "$LSM"_LST_"$exp_out"_"$y_0"_"$y_n".nc "$LSM"_LST_"$exp_out"_Annual.nc   
cdo yearmonmean "$LSM"_SH_"$exp_out"_"$y_0"_"$y_n".nc "$LSM"_SH_"$exp_out"_Annual.nc
cdo yearmonmean "$LSM"_ET_"$exp_out"_"$y_0"_"$y_n".nc "$LSM"_ET_"$exp_out"_Annual.nc
cdo yearmonmean "$LSM"_SoilM_"$exp_out"_"$y_0"_"$y_n".nc "$LSM"_SoilM_"$exp_out"_Annual.nc
cdo yearmonmean "$LSM"_NEE_"$exp_out"_"$y_0"_"$y_n".nc "$LSM"_NEE_"$exp_out"_Annual.nc
cdo yearmonmean "$LSM"_GPP_"$exp_out"_"$y_0"_"$y_n".nc "$LSM"_GPP_"$exp_out"_Annual.nc
cdo yearmonmean "$LSM"_AboBm_"$exp_out"_"$y_0"_"$y_n".nc "$LSM"_AboBm_"$exp_out"_Annual.nc

# annual mean

cdo timmean "$LSM"_Albedo_"$exp_out"_"$y_0"_"$y_n".nc "$LSM"_Albedo_"$exp_out"_30yr_Mean.nc 
cdo timmean "$LSM"_LST_"$exp_out"_"$y_0"_"$y_n".nc "$LSM"_LST_"$exp_out"_30yr_Mean.nc   
cdo timmean "$LSM"_SH_"$exp_out"_"$y_0"_"$y_n".nc "$LSM"_SH_"$exp_out"_30yr_Mean.nc
cdo timmean "$LSM"_ET_"$exp_out"_"$y_0"_"$y_n".nc "$LSM"_ET_"$exp_out"_30yr_Mean.nc
cdo timmean "$LSM"_SoilM_"$exp_out"_"$y_0"_"$y_n".nc "$LSM"_SoilM_"$exp_out"_30yr_Mean.nc
cdo timmean "$LSM"_NEE_"$exp_out"_"$y_0"_"$y_n".nc "$LSM"_NEE_"$exp_out"_30yr_Mean.nc
cdo timmean "$LSM"_GPP_"$exp_out"_"$y_0"_"$y_n".nc "$LSM"_GPP_"$exp_out"_30yr_Mean.nc
cdo timmean "$LSM"_AboBm_"$exp_out"_"$y_0"_"$y_n".nc "$LSM"_AboBm_"$exp_out"_30yr_Mean.nc

rm -rf tmp*.nc

done 

exit
