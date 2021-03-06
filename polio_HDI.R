setwd("~/desktop/polio")


require('tidyr')
h = read.csv('HDI_original.csv')
h_long = gather(h, year, HDI, X2015:X1990)
h_long$year = as.numeric(substr(h_long$year, 2, 5))
h_long$Country = trimws(h_long$Country)

p = read.csv('population_size.csv')


d_long = read.csv('incidence-long.csv')
names(d_long)[names(d_long) == 'Cname'] = 'Country'

c = read.csv('coverage.csv')
c_long = gather(c, year, coverage, X2016:X1980)
c_long$year = as.numeric(substr(c_long$year, 2, 5))

p = read.csv('population_size.csv')
p_long = gather(p, year, pop, X2015:X1990)
p_long$year = as.numeric(substr(p_long$year, 2, 5))
names(p_long)[names(p_long) == 'Country.Name'] = 'Country'

merged_data = merge(c_long, h_long[,c('Country', 'year', 'HDI')])
merged_data = merge(merged_data, d_long[,c('Country', 'year', 'incidence')])
merged_data = merge(merged_data, p_long[,c('Country', 'year', 'pop')])
merged_data$coverage = merged_data$coverage/100
attach(merged_data)

incidence = merged_data$incidence
HDI = merged_data$HDI
coverage = merged_data$coverage
pop = merged_data$pop


logreg = glm(incidence!=0 ~ HDI + coverage, family = binomial(link = 'logit'))
nbreg = glm(incidence!=0 ~ HDI + coverage, family = negative.binomial(theta = 1), offset = log(pop))

summary(logreg)
summary(nbreg)
detach(merged_data)

confint(nbreg)
