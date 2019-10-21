# Data Scrapping form the European Medicines Agency (EMA)
## *Miquel Anglada Girotto*

The [European Medicines Agency (EMA)](https://www.ema.europa.eu/en), together with the [Food and Drugs Administration (FDA)](https://www.fda.gov/) and [National Medical Products Administration (NMPA)](http://www.nmpa.gov.cn/WS04/CL2042/), is one of the main institutions through which every small or large pharmaceutical company needs to interact to develop and authorize marketing new drugs.

In addition, harmonization of (pre)clinical trials like safety, dosage or efficacy (e.g. [ICH Guidelines](https://www.ich.org/)) facilitated the approval of New Drug Applications (NDA) in multiple countries in parallel; without the need of repeating the experiments.

Usually, most of the countries in the world accept NDAs approved in one of the aforementioned three main drug agencies.
Therefore, improving data accessibility to these agencies may facilitate better planning of forthcoming NDAs.
The EMA's webpage stores a large amount of publicly available information that is only accessible through navigation but not for unbiased exploration.

Here, I developed a small library called `EMA_webScrapping` based on the package `RSelenium` to scrap and explore the information published for each drug in the EMA.

### Index:
0. Required packages and tailored functions
1. Set Initial parameters
2. Download information from each drug
3. Save information
4. Exploratory Data Analysis
