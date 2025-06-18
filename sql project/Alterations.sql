ALTER TABLE `nifty_50`.`nifty_analysis` 
CHANGE COLUMN `ï»¿Date` `Date` DATE NOT NULL ,
ADD PRIMARY KEY (`Date`);
ALTER TABLE `nifty_50`.`nifty_analysis` 
CHANGE COLUMN `Date` `_Date` DATE NOT NULL ;
ALTER TABLE `nifty_50`.`nifty_analysis` 
CHANGE COLUMN `Price` `Close` DOUBLE NULL DEFAULT NULL ;
ALTER TABLE `nifty_50`.`nifty_analysis` 
CHANGE COLUMN `Close` `Closing` DOUBLE NULL DEFAULT NULL ,
CHANGE COLUMN `Open` `Opening` DOUBLE NULL DEFAULT NULL ;