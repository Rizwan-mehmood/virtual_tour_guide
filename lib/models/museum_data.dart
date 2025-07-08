class Museum {
  final String name;
  final String description;
  final String architectName;
  final String yearOpened;
  final String location;
  final String logoUrl;
  final String mainImageUrl;
  final List<String> galleryImages;
  final List<String> facts;
  final VisitorInfo visitorInfo;
  final List<Exhibition> exhibitions;
  final List<Artwork> featuredArtworks;

  Museum({
    required this.name,
    required this.description,
    required this.architectName,
    required this.yearOpened,
    required this.location,
    required this.logoUrl,
    required this.mainImageUrl,
    required this.galleryImages,
    required this.facts,
    required this.visitorInfo,
    required this.exhibitions,
    required this.featuredArtworks,
  });

  // Sample data for Louvre Abu Dhabi
  static Museum louvreAbuDhabi() {
    return Museum(
      name: 'Louvre Abu Dhabi',
      description:
          'Louvre Abu Dhabi is an art and civilization museum located in Abu Dhabi, United Arab Emirates. The museum is located on Saadiyat Island Cultural District. It is approximately 24,000 square metres in size, with 8,000 square metres of galleries, making it the largest art museum in the Arabian peninsula. The final cost of the construction is expected to be about €600 million. In addition, US\$525 million was paid by Abu Dhabi to be associated with the Louvre name, and an additional US\$747 million will be paid in exchange for art loans, special exhibitions and management advice.',
      architectName: 'Jean Nouvel',
      yearOpened: '2017',
      location:
          'Saadiyat Island Cultural District, Abu Dhabi, United Arab Emirates',
      logoUrl:
          'https://destinationreporterindia.com/wp-content/uploads/2018/11/DR-abudhabi_web.jpg',
      mainImageUrl:
          'https://medias-distribution.lab.arte.tv/photos/0914434-cropped.jpg',
      galleryImages: [
        'https://www.johndesmond.com/wp-content/uploads/2019/06/light-and-geometry-louvre-abu-dhabi_01.jpg',
        'https://www.absoluteproduct.com/images/pages/1577-Absolute-Museum-Gallery-Products-Louvre-Abu-Dhabi-Unsplash-8.jpg',
        'https://www.neumannmueller.com/fileadmin/_processed_/9/6/csm_Louvre_Abu_Dhabi_7_c5693e4c68.jpg',
        'https://www.donenright.com/wp-content/uploads/2018/02/untitled-31.jpg',
        'https://i.ndtvimg.com/i/2016-06/abu-dhabis-louvre-museum_650x400_81466001439.jpg',
      ],
      facts: [
        'The dome is 180 meters in diameter and weighs approximately 7,500 tons.',
        'The dome creates a "rain of light" effect, inspired by the palm trees of Abu Dhabi.',
        'The museum contains artworks from around the world, with a particular focus on bridging the gap between Eastern and Western art.',
        'The construction took over 10 years to complete.',
        'The museum has a permanent collection of over 600 artworks.',
        'The "rain of light" effect is created by the sun filtering through the 8 layers of geometric patterns in the dome.',
        'The building appears to float on water, with the Arabian Gulf surrounding it.',
      ],
      visitorInfo: VisitorInfo(
        openingHours: [
          OpeningHours(day: 'Tuesday', hours: '10:00 AM - 6:30 PM'),
          OpeningHours(day: 'Wednesday', hours: '10:00 AM - 6:30 PM'),
          OpeningHours(day: 'Thursday', hours: '10:00 AM - 6:30 PM'),
          OpeningHours(day: 'Friday', hours: '10:00 AM - 8:30 PM'),
          OpeningHours(day: 'Saturday', hours: '10:00 AM - 8:30 PM'),
          OpeningHours(day: 'Sunday', hours: '10:00 AM - 6:30 PM'),
          OpeningHours(day: 'Monday', hours: 'Closed'),
        ],
        ticketPrices: [
          TicketPrice(type: 'General Admission', price: 'AED 63'),
          TicketPrice(type: 'Reduced (13-22 years)', price: 'AED 31.5'),
          TicketPrice(type: 'Children (< 13 years)', price: 'Free'),
          TicketPrice(type: 'Art Club Members', price: 'Free'),
        ],
        mapUrl: 'https://www.inat.fr/files/wayfinding-louvre-abu-dhabi-map.png',
        location: {
          'latitude': 24.5333,
          'longitude': 54.3981,
          'address': 'Saadiyat Cultural District, Saadiyat Island, Abu Dhabi',
        },
        facilities: [
          'Restaurant & Café',
          'Museum Shop',
          'Prayer Rooms',
          'Free WiFi',
          'Wheelchair Access',
          'Coat Check',
          'ATM',
          'First Aid',
        ],
      ),
      exhibitions: [
        Exhibition(
          title: 'Cartier, Islamic Inspiration and Modern Design',
          imageUrl:
              'https://ujoydisplay.com/wp-content/uploads/2021/01/Cartier-jewelry-display-showcase_ujoydisplay-5.jpg',
          dateRange: 'September 15, 2023 - January 28, 2024',
          description:
              'Explore the profound influence of Islamic art on Cartier\'s designs throughout the 20th century. The exhibition presents over 400 objects, including jewelry, clocks, accessories, and archival documents, revealing how Islamic motifs and techniques inspired Louis Cartier and his designers.',
          artworks: [
            Artwork(
              title: 'Cartier Tutti Frutti Necklace',
              artist: 'Cartier',
              year: '1936',
              imageUrl:
                  'https://int.cartier.com/content/dam/cartier_dam/catalogue_assets/manhattan-update/1-jewelry/high-jewellery/2-markers-of-style/tutti-frutti/MP1_HJ_tutti_frutti_top.png.scale.1600.800.high.png',
              description:
                  'A stunning example of Cartier\'s "Tutti Frutti" style, incorporating carved colored gemstones inspired by Mughal art.',
              type: 'Jewelry',
            ),
            Artwork(
              title: 'Oriental Tiara',
              artist: 'Cartier',
              year: '1920',
              imageUrl:
                  'https://erstwhilejewelry.com/cdn/shop/articles/antique-tiaras-from-cartier-909509.jpg?v=1697142962',
              description:
                  'A platinum and diamond tiara featuring Islamic-inspired geometric patterns.',
              type: 'Jewelry',
            ),
          ],
        ),
        Exhibition(
          title: 'Abstraction and Calligraphy',
          imageUrl:
              'https://cloudfront-eu-central-1.images.arcpublishing.com/thenational/LSDKLV6422SYRN3I7IWJHGMBME.jpg',
          dateRange: 'February 17, 2023 - May 28, 2023',
          description:
              'This exhibition explores the relationship between abstract art and calligraphy, highlighting how written gestures influenced modern abstraction in both Western and Eastern traditions.',
          artworks: [
            Artwork(
              title: 'Untitled',
              artist: 'Mark Rothko',
              year: '1952',
              imageUrl:
                  'https://www.pacegallery.com/media/images/10808_JgohBXz.width-2000.jpg',
              description:
                  'A characteristic Rothko painting featuring luminous rectangles of color.',
              type: 'Painting',
            ),
            Artwork(
              title: 'Composition VII',
              artist: 'Wassily Kandinsky',
              year: '1913',
              imageUrl:
                  'https://www.louvreabudhabi.ae/-/media/images-2021/exhibitions/1-kandinsky-3.jpg?rev=98cfde292462427786fc246ba41a55b0',
              description:
                  'One of Kandinsky\'s most complex works, showing the influence of musical composition on visual art.',
              type: 'Painting',
            ),
          ],
        ),
        Exhibition(
          title:
              'Dragon and Phoenix: Centuries of Exchange between Chinese and Islamic Worlds',
          imageUrl:
              'https://www.mei.edu/sites/default/files/Jackie%2520Image%252012.jpg',
          dateRange: 'October 6, 2022 - February 12, 2023',
          description:
              'This exhibition explores the cultural exchanges between China and the Islamic world from the 8th to the 18th century, featuring ceramics, glassware, precious metals, and textiles.',
          artworks: [
            Artwork(
              title: 'Blue and White Porcelain Jar',
              artist: 'Unknown Chinese Artist',
              year: '15th century',
              imageUrl: 'https://www.worldhistory.org/uploads/images/9996.jpg',
              description:
                  'A Ming dynasty porcelain jar with cobalt blue decorations showing Islamic influence.',
              type: 'Ceramics',
            ),
            Artwork(
              title: 'Silk Tapestry with Dragon Motifs',
              artist: 'Unknown',
              year: '14th century',
              imageUrl:
                  'https://zacke.blob.core.windows.net/stock/13724-6-medium.jpg?v=63806448688093',
              description:
                  'A silk tapestry combining Chinese dragon motifs with Islamic artistic patterns.',
              type: 'Textile',
            ),
          ],
        ),
      ],
      featuredArtworks: [
        Artwork(
          title: 'La Belle Ferronnière',
          artist: 'Leonardo da Vinci',
          year: 'c. 1490',
          imageUrl:
              'https://upload.wikimedia.org/wikipedia/commons/4/4d/La_Belle_Ferroni%C3%A8re_-_Google_Arts.jpg',
          description:
              'This portrait is thought to depict Lucrezia Crivelli, a mistress of Ludovico Sforza, Duke of Milan. The painting is one of only 15 surviving paintings by Leonardo da Vinci and was acquired by the Louvre Abu Dhabi in 2016.',
          type: 'Painting',
        ),
        Artwork(
          title: 'Portrait of a Woman',
          artist: 'Pablo Picasso',
          year: '1928',
          imageUrl:
              'https://lad-api.fluxguide.dev/uploads/large/100322660__56e40c83-791c-4974-bbce-b0844b43abdb.jpg',
          description:
              'A characteristic example of Picasso\'s work from his Surrealist period, showing his distinctive style of portraiture with distorted features.',
          type: 'Painting',
        ),
        Artwork(
          title: 'Children Wrestling',
          artist: 'Paul Gauguin',
          year: '1888',
          imageUrl:
              'https://lad-api.fluxguide.dev/uploads/large/100321209__23cc8d6e-362e-495f-acfe-0dc2f7287b39.jpg',
          description:
              'A painting depicting Breton children wrestling, showcasing Gauguin\'s post-impressionist style with flattened forms and bold colors.',
          type: 'Painting',
        ),
        Artwork(
          title: 'Fountain of Light',
          artist: 'Ai Weiwei',
          year: '2016',
          imageUrl:
              'https://lad-api.fluxguide.dev/uploads/large/100321434__295d775d-bd98-4e23-8e2d-548bb36b133f.jpg',
          description:
              'A monumental chandelier-like sculpture inspired by Vladimir Tatlin\'s "Monument to the Third International" (1919). The sculpture consists of glass crystals and stainless steel.',
          type: 'Sculpture',
        ),
        Artwork(
          title: 'The Belvedere',
          artist: 'Giovanni Paolo Panini',
          year: '1758',
          imageUrl:
              'https://upload.wikimedia.org/wikipedia/commons/thumb/5/58/Galerie_de_vues_de_la_Rome_antique_-_Giovanni_Paolo_Pannini_-_Mus%C3%A9e_du_Louvre_Peintures_RF_1944_21.jpg/1200px-Galerie_de_vues_de_la_Rome_antique_-_Giovanni_Paolo_Pannini_-_Mus%C3%A9e_du_Louvre_Peintures_RF_1944_21.jpg',
          description:
              'A detailed architectural painting depicting the Belvedere Courtyard in the Vatican, showcasing Panini\'s mastery of perspective and architectural detail.',
          type: 'Painting',
        ),
        Artwork(
          title: 'Astrolabe',
          artist: 'Unknown',
          year: '14th century',
          imageUrl:
              'https://lad-api.fluxguide.dev/uploads/large/100321572__dd885aed-951b-4737-9c63-6faf74aed434.jpg',
          description:
              'An astronomical instrument used to determine the position of the sun and stars. This example showcases the scientific advancement of Islamic civilization.',
          type: 'Scientific Instrument',
        ),
      ],
    );
  }
}

class VisitorInfo {
  final List<OpeningHours> openingHours;
  final List<TicketPrice> ticketPrices;
  final String mapUrl;
  final Map<String, dynamic> location;
  final List<String> facilities;

  VisitorInfo({
    required this.openingHours,
    required this.ticketPrices,
    required this.mapUrl,
    required this.location,
    required this.facilities,
  });
}

class OpeningHours {
  final String day;
  final String hours;

  OpeningHours({required this.day, required this.hours});
}

class TicketPrice {
  final String type;
  final String price;

  TicketPrice({required this.type, required this.price});
}

class Exhibition {
  final String title;
  final String imageUrl;
  final String dateRange;
  final String description;
  final List<Artwork> artworks;

  Exhibition({
    required this.title,
    required this.imageUrl,
    required this.dateRange,
    required this.description,
    required this.artworks,
  });
}

class Artwork {
  final String title;
  final String artist;
  final String year;
  final String imageUrl;
  final String description;
  final String type;

  Artwork({
    required this.title,
    required this.artist,
    required this.year,
    required this.imageUrl,
    required this.description,
    required this.type,
  });
}
