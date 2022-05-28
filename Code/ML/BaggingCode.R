
##########################Change only this section####################################

#remove everything but the function reg_rf
rm(list= ls()[!(ls() %in% c('reg_rf','new.data'))])
item="622"

#declaring variable lists
#all features

varlist = c("MODEL","REFILL_OR_NEW_CARTRIDGE")
ivars=c("MODEL","REFILL_OR_NEW_CARTRIDGE")
nvars=c()
########################################################################################


#calling data to be used
for (i in item){
  itemdata <- read.dta13(paste0("C:/Users/saksh/Dropbox/PunjabProcurement/Data/Item Data/ML/CleanData/SG/Item",i,".dta"))
}
names(itemdata)
str(itemdata)


#Character variables to Factor Variables

itemdata_control <- subset(itemdata, (Treatment ==4 | Treatment==5) & TrimmedSample==1) 
itemdata_treat <- subset(itemdata, (Treatment ==1 | Treatment==2 | Treatment==3) & TrimmedSample==1) 

itemdata_control <- as.data.frame(unclass(itemdata_control))
str(itemdata_control)

itemdata_treat <- as.data.frame(unclass(itemdata_treat))
str(itemdata_treat)



#fitting the tree using function defined above -> reg_rf
formula = as.formula(paste0("lpriceHat", " ~ ", paste0(varlist, collapse =  " + ")))
tree.item929 = reg_rf(formula,n_trees=500,feature_frac=2/3, data=itemdata_control)

#varlist.nm is the list of variables which have a mismatch - declare later
#This doesn't work- check how to make this work to see which variable goes in varlist2(the vars with a mismatch)

itemdata_control[nvars] <- lapply(itemdata_control[nvars],as.factor)
itemdata_treat[nvars] <- lapply(itemdata_treat[nvars],as.factor)

str(itemdata_control)

algo.need = lapply(varlist, function(thisvar){
  print(isTRUE(any(!(levels(itemdata_treat[,thisvar]) %in% levels(itemdata_control[,thisvar])))))
})

algo.need.var = lapply(varlist, function(thisvar){
  print(thisvar)
})

algo.need=unlist(algo.need)
algo.need.var=unlist(algo.need.var)
algo=as.data.frame(cbind(algo.need,algo.need.var))

#feautures for which we need to run an algorithm - varlist.nm
varlist.nm=as.vector(subset(algo,algo$algo.need=="TRUE")[,2])
varlist.m=as.vector(subset(algo,algo$algo.need=="FALSE")[,2])


if (length(varlist.nm)>0){
nvar.nm=subset(varlist.nm,varlist.nm %in% nvars)
ivar.nm=subset(varlist.nm,varlist.nm %in% ivars)

rm(algo,algo.need,algo.need.var)

#find the observations from the treatment data which cannot be put in leaves - nomatch.t
nomatch.t = lapply(varlist.nm, function(thisvar){
  subset(itemdata_treat,!(as.character(itemdata_treat[,thisvar]) %in% levels(itemdata_control[,thisvar]))) 
})
nomatch.t=unique(do.call(rbind,nomatch.t))

#find the observations from the treatment data which can be put in leaves - match.t
match.t=subset(itemdata_treat,!(itemdata_treat$DeliveryID %in% nomatch.t$DeliveryID))

ind = lapply(varlist.nm, function(thisvar){
  paste0("ind_",thisvar)
})

ind=unlist(ind)

indicator = lapply(varlist.nm, function(thisvar){
  nomatch.t[,ind] = ifelse((nomatch.t[,thisvar])  %in%  levels(itemdata_control[,thisvar]),0, 1)
})

indicator=as.data.frame(do.call(cbind,indicator))
colnames(indicator)=ind

nomatch.t=cbind(nomatch.t,indicator)


#dealing with numerical variables here - just replacing them with the closest value available in the control group.
#incase there are two closest values then lower value assigned as of now

if (length(nvar.nm)>0){
for (i in nvar.nm){ 
  for (r in 1:nrow(nomatch.t)){
    if (nomatch.t[r,paste0("ind_",i)]==1){
      nomatch.t[r,paste0(i,"_new")]=min(Closest(as.numeric(levels(itemdata_control[,i])),as.numeric(as.character(nomatch.t[r,i])))) 
      nomatch.t[r,paste0("dist_",i)]=abs(as.numeric(nomatch.t[r,paste0(i,"_new")])-as.numeric(as.character(nomatch.t[r,i])))
    }
    else {nomatch.t[r,paste0(i,"_new")]=as.numeric(as.character(nomatch.t[r,i])) 
    nomatch.t[r,paste0("dist_",i)]=0}
  }
}
}

#For categorical variables replace the category with prices closest in treatment group or if missing then control group

if (length(ivar.nm)>0){
itemdata.avgPrice = subset(itemdata,Treatment>0 & Treatment<6 & TrimmedSample==1) 
itemdata.avgPrice$Treat = ifelse(itemdata.avgPrice$Treatment==4|itemdata.avgPrice$Treatment==5,0,itemdata.avgPrice$Treatment)

itemdata.avgPrice <- as.data.frame(unclass(itemdata.avgPrice))


treat1=subset(itemdata.avgPrice,Treat==1)
treat2=subset(itemdata.avgPrice,Treat==2)
treat3=subset(itemdata.avgPrice,Treat==3)

control= lapply(ivar.nm, function(thisvar){
  aggregate(itemdata_control$lpriceHat,by=list(itemdata_control[,thisvar]),mean,na.rm=TRUE)
})

t1= lapply(ivar.nm, function(thisvar){
  aggregate(treat1$lpriceHat ,by=list(treat1[,thisvar]),mean,na.rm=TRUE)
})
t2= lapply(ivar.nm, function(thisvar){
  aggregate(treat2$lpriceHat ,by=list(treat2[,thisvar]),mean,na.rm=TRUE)
})
t3= lapply(ivar.nm, function(thisvar){
  aggregate(treat3$lpriceHat ,by=list(treat3[,thisvar]),mean,na.rm=TRUE)
})

data.merge = list() 
col.names=c("group","lpriceHat_control","lpriceHat_t1","lpriceHat_t2","lpriceHat_t3")

for (i in 1:length(ivar.nm)){
  data.merge[[i]]=merge(merge(merge(control[[i]],t1[[i]],by=c("Group.1"),all.x = TRUE),t2[[i]],by=c("Group.1"),all.x = TRUE),t3[[i]],by=c("Group.1"),all.x = TRUE)
  for (r in 1:nrow(data.merge[[i]])){
    for (col in 3:ncol(data.merge[[i]])){
      if (is.na(data.merge[[i]][r,col])) {data.merge[[i]][r,col]= data.merge[[i]][r,2]}
    }  
    colnames(data.merge[[i]])=col.names
    assign(paste0(ivar.nm[[i]]), data.frame(data.merge[[i]]))
    
  }
  
}

rm(treat1,t1,control,treat2,t2,treat3,t3) 

for (r in 1:nrow(nomatch.t)){
  for (i in ivar.nm){
    n=  which(ivar.nm==i)
    if (nomatch.t[r,paste0("ind_",i)]==1 & nomatch.t$Treatment[r]==1){
      nomatch.t[r,paste0(i,"_new")]=as.character(data.merge[[n]][(Closest(data.merge[[n]]$lpriceHat_t1,nomatch.t$lpriceHat[r],which=TRUE)),1])
      nomatch.t[r,paste0("dist_",i)]=abs(Closest(data.merge[[n]]$lpriceHat_t1,nomatch.t$lpriceHat[r])-nomatch.t$lpriceHat[r])
    }
    
    else if (nomatch.t[r,paste0("ind_",i)]==1 & nomatch.t$Treatment[r]==2){
      nomatch.t[r,paste0(i,"_new")]=as.character(data.merge[[n]][(Closest(data.merge[[n]]$lpriceHat_t2,nomatch.t$lpriceHat[r],which=TRUE)),1])
      nomatch.t[r,paste0("dist_",i)]=abs(Closest(data.merge[[n]]$lpriceHat_t2,nomatch.t$lpriceHat[r])-nomatch.t$lpriceHat[r])
    }
    
    else if (nomatch.t[r,paste0("ind_",i)]==1 & nomatch.t$Treatment[r]==3){
      nomatch.t[r,paste0(i,"_new")]=as.character(data.merge[[n]][(Closest(data.merge[[n]]$lpriceHat_t3,nomatch.t$lpriceHat[r],which=TRUE)),1])
      nomatch.t[r,paste0("dist_",i)]=abs(Closest(data.merge[[n]]$lpriceHat_t3,nomatch.t$lpriceHat[r])-nomatch.t$lpriceHat[r])
    }
    
    else {
      nomatch.t[r,paste0(i,"_new")]=as.character(nomatch.t[r,i])
      nomatch.t[r,paste0("dist_",i)]=0
    }
  }
}

}
#replace old values with new values in the nomatch data
for(i in varlist.nm){
  nomatch.t[, i] = nomatch.t[,paste0(i,"_new")]
}

nomatch.t[nvars] <- lapply(nomatch.t[nvars],as.character)
nomatch.t[nvars] <- lapply(nomatch.t[nvars],as.numeric)

mat.929.nmatch.t <- matrix(, nrow = nrow(nomatch.t), ncol =500)
for(column in 1:500){
  mat.929.nmatch.t[, column] <- predict(tree.item929[[column]],nomatch.t, type = "vector")
}

avg.predict.nt = rowMeans(mat.929.nmatch.t)
distance= lapply(varlist.nm, function(thisvar){
  nomatch.t[,paste0("dist_",thisvar)] 
})

distance.matrix = do.call(cbind,distance)

variance=lapply(varlist.nm,function(thisvar){
  if (thisvar %in% ivar.nm) {n=which(ivar.nm==thisvar) 
  var(data.merge[[n]][,2])  }
  else if (thisvar %in% nvar.nm) {
    var(as.numeric(as.character(itemdata_control[,thisvar])))
  }
})

variance.dist=unlist(variance)
mean.dist=matrix(0,nrow=nrow(nomatch.t),ncol=length(varlist.nm))
cov=variance.dist*diag(length(varlist.nm))

nomatch.dist = mahalanobis(distance.matrix, mean.dist, cov, inverted = FALSE)
nomatch.t[ , "rf.pred.lprice"] = avg.predict.nt
nomatch.t[ , "distance"] = nomatch.dist

nomatch.t= nomatch.t[ , -grep("ind_", names(nomatch.t))]
nomatch.t= nomatch.t[ , -grep("dist_", names(nomatch.t))]
nomatch.t <- nomatch.t %>% select(-contains("_new"))


}

#converting data back to the form used for fitting trees

if (length(varlist.nm)==0){
  match.t=itemdata_treat
}

match.t[nvars] = lapply(match.t[nvars],as.character)
match.t[nvars] = lapply(match.t[nvars],as.numeric)


itemdata_control[nvars] = lapply(itemdata_control[nvars],as.character)
itemdata_control[nvars] = lapply(itemdata_control[nvars],as.numeric)


mat.929.c <- matrix(, nrow = nrow(itemdata_control), ncol =500)
for(column in 1:500){
  mat.929.c[, column] <- predict(tree.item929[[column]],itemdata_control, type = "vector")
}

mat.929.t <- matrix(, nrow = nrow(match.t), ncol =500)
for(column in 1:500){
  mat.929.t[, column] <- predict(tree.item929[[column]],match.t, type = "vector")
}


avg.predict.c = rowMeans(mat.929.c)
avg.predict.t = rowMeans(mat.929.t)

#only include variables which have a mismatch

distance=rep(0, nrow(match.t))

match.t[ , "rf.pred.lprice"] = avg.predict.t
match.t[,"distance"] = distance

itemdata_control[ , "rf.pred.lprice"] = avg.predict.c
distance=rep(0, nrow(itemdata_control))
itemdata_control[ , "distance"] = distance

if (length(varlist.nm)>0){
for (i in item){ 
itemdata_rf = rbind(itemdata_control,match.t,nomatch.t)
for (v in varlist.nm){
itemdata_rf[,paste0(v,"_new")]=itemdata_rf[,v]
itemdata_rf=itemdata_rf[,!(names(itemdata_rf) %in% v)] 
}  
itemdata_rf=merge(itemdata_rf,itemdata[,c("DeliveryID",varlist.nm)],by='DeliveryID',all.x=TRUE)
write.dta(itemdata_rf, paste0("C:/Users/saksh/Dropbox/PunjabProcurement/Data/Item Data/ML/CleanData/SG/Item",i,"_rf.dta"))
}
}

if (length(varlist.nm)==0){
  for (i in item){ 
    itemdata_rf = rbind(itemdata_control,match.t)
    write.dta(itemdata_rf, paste0("C:/Users/saksh/Dropbox/PunjabProcurement/Data/Item Data/ML/CleanData/SG/Item",i,"_rf.dta"))
  }
}



