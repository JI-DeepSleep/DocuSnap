# Getting Started

# Model and Engine

# APIs and Controller

**Request Parameters**
| Key        | Location       | Type   | Description  |
| ---------- | -------------- | ------ | ------------ |
| `username` | Session Cookie | String | Current User |

**Response Codes**
| Code              | Description        |
| ----------------- | ------------------ |
| `200 OK`          | Success            |
| `400 Bad Request` | Invalid parameters |

**Returns**

*If no user is logged in or no posts created by user*
| Key             | Location | Type                      | Description                                  |
| --------------- | -------- | ------------------------- | -------------------------------------------- |
| `popular_songs` | JSON     | List of Spotify Track IDs | Top 25 songs on Spotify in the United States |

*For logged-in users with 1 or more posts created*
| Key                         | Location | Type                      | Description                                                                                             |
| --------------------------- | -------- | ------------------------- | ------------------------------------------------------------------------------------------------------- |
| `attribute_recommendations` | JSON     | List of Spotify Track IDs | Attribute-based recommendations (random genres)                                                         |
| `genre_recommendations`     | JSON     | List of Spotify Track IDs | Attribute and genre-based recommendations based on user's favorite genres                               |
| `artist_recommendations`    | JSON     | List of Spotify Track ID  | Attribute and artist-based recommendations based on user's favorite artists                             |
| `attribute_error`           | JSON     | Dictionary                | contains the average error % for each attribute between recommendation and the user's attribute vector. |

**Example**
~~~ 
curl -b cookies.txt -c cookies.txt -X GET https://OUR_SERVER/recommendations/'

{
    "attribute_error": {
        "acousticness": 0.1342,
        "danceability": 0.2567,
        "energy": 0.1144,
        "instrumentalness": 0.021,
        "liveness": 0.0324,
        "loudness": 0.0084,
        "speechiness": 0.0528,
        "tempo": 0.0446,
        "valence": 0.1538
    },
    "attribute_recommendations": [
        "spotify:track:3joo84oco9CD4dBsKNWRRW",
        "spotify:track:5DxlyLbSTkkKjJPGCoMo1O",
        ...
    ],
    "genre_recommendations": [
        "spotify:track:4MzXwWMhyBbmu6hOcLVD49",
        "spotify:track:0bYg9bo50gSsH3LtXe2SQn",
        ...
    ],
    "artist_recommendations": [
        "spotify:track:2EjXfH91m7f8HiJN1yQg97",
        "spotify:track:5o8EvVZzvB7oTvxeFB55UJ",
        ...
    ],
    "url": "/recommendations/"
}
~~~

## Third-Party SDKs

# View UI/UX

# Team Roster