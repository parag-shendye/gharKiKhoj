require('dotenv').config();
const puppeteer = require('puppeteer');
const { createClient } = require('@supabase/supabase-js');
const supabaseUrl = process.env.SUPABASE_URI
const supabaseKey = process.env.SUPABASE_KEY
const supabase = createClient(supabaseUrl, supabaseKey)
const api = process.env.API

const parseCost = (price) =>{
  return price.match(/\d+/g) ? parseInt(price.match(/\d+/g).join('')) : -1;
}

const parseFeature = (v) =>{
  return v.match(/\d+/g) ? parseInt(v.match(/\d+/g).join('')) : -1;
}


const updateData = async (entry) => {
  const { data, error } = await supabase
  .from('apartments')
  .insert({
    city: entry["city"],
    title: entry["title"],
    address: entry["subtitle"],
    price: parseCost(entry["price"]),
    floor_area: parseFeature(entry["features"][0]),
    rooms: parseFeature(entry["features"][1]),
    furnished: entry["features"][2],
    href: entry["href"],
    duration: entry["Duration"],
    available: entry["Available"],
    energy: entry["Energy rating"]
  })
  .select();

  return {data, error}
}


const getData = async (city) => {
  let browser;
  try {

      browser = await puppeteer.launch();

      const page = await browser.newPage();

      const url = `${api}/apartments/${city}`;
      await page.goto(url, { waitUntil: 'networkidle2' });

      await page.waitForSelector('.listing-search-item__link--title', { timeout: 10000 });

      const listings = await page.evaluate(() => {


          const items = Array.from(document.querySelectorAll('.listing-search-item__link--title')).map(titleElement => {
              const item = titleElement.closest('.listing-search-item');
              const hrefE = titleElement.getAttribute('href');
              const subtitleElement = item.querySelector('.listing-search-item__sub-title\\\'');
              const priceElement = item.querySelector('.listing-search-item__price');
              const featuresElement = item.querySelector('.illustrated-features');

              const features = featuresElement ? Array.from(featuresElement.querySelectorAll('li')).map(li => li.textContent.trim()) : [];

              return {
                  title: titleElement ? titleElement.textContent.trim() : '',
                  href: `${document.URL}${hrefE}`,
                  subtitle: subtitleElement ? subtitleElement.textContent.trim() : '',
                  price: priceElement ? priceElement.textContent.trim() : '',
                  features: features
              };
          });

          return items;
      });
      for (let listing of listings) {
        await page.goto(listing.href, { waitUntil: 'domcontentloaded' });
    
        const data = await page.evaluate(() => {
          const features = document.querySelectorAll('.listing-features__list dt');
          const values = document.querySelectorAll('.listing-features__list dd .listing-features__main-description');
          
          const featureMap = {};
          
          features.forEach((feature, index) => {
            const featureName = feature.textContent.trim();
            const value = values[index].textContent.trim();
            if (["Duration", "Energy rating", "Available"].includes(featureName)) {
              featureMap[featureName] = value;
              // listing[featureName] = value;
            }
          });
      
          return featureMap;
        });
        
      for (const [key, value] of Object.entries(data)) {
        listing[key] = value;
      }
        // console.log(data);
      }
      return listings;

  } catch (error) {
      console.error('Error:', error);
      return [];
  } finally {
      if (browser) {
          await browser.close();
      }
  }
};

(async () => {
  try {
      const city = process.argv[2].trim();
      const listings = await getData(city);
      for (let index = 0; index < listings.length; index++) {
        var element = listings[index];
        element["city"] = city;
        await updateData(element);
      }
      console.log('Extracted Listings:', listings);
  } catch (error) {
      console.error('Error fetching data:', error);
  }
})();

