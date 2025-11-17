-- __/\\\\\\\\\\\__/\\\\\_____/\\\__/\\\\\\\\\\\\\\\____/\\\\\_________/\\\\\\\\\_________/\\\\\\\________/\\\\\\\________/\\\\\\\________/\\\\\\\\\\________________/\\\\\\\\\_______/\\\\\\\\\_____        
--  _\/////\\\///__\/\\\\\\___\/\\\_\/\\\///////////___/\\\///\\\_____/\\\///////\\\_____/\\\/////\\\____/\\\/////\\\____/\\\/////\\\____/\\\///////\\\_____________/\\\\\\\\\\\\\___/\\\///////\\\___       
--   _____\/\\\_____\/\\\/\\\__\/\\\_\/\\\____________/\\\/__\///\\\__\///______\//\\\___/\\\____\//\\\__/\\\____\//\\\__/\\\____\//\\\__\///______/\\\_____________/\\\/////////\\\_\///______\//\\\__      
--    _____\/\\\_____\/\\\//\\\_\/\\\_\/\\\\\\\\\\\___/\\\______\//\\\___________/\\\/___\/\\\_____\/\\\_\/\\\_____\/\\\_\/\\\_____\/\\\_________/\\\//_____________\/\\\_______\/\\\___________/\\\/___     
--     _____\/\\\_____\/\\\\//\\\\/\\\_\/\\\///////___\/\\\_______\/\\\________/\\\//_____\/\\\_____\/\\\_\/\\\_____\/\\\_\/\\\_____\/\\\________\////\\\____________\/\\\\\\\\\\\\\\\________/\\\//_____    
--      _____\/\\\_____\/\\\_\//\\\/\\\_\/\\\__________\//\\\______/\\\______/\\\//________\/\\\_____\/\\\_\/\\\_____\/\\\_\/\\\_____\/\\\___________\//\\\___________\/\\\/////////\\\_____/\\\//________   
--       _____\/\\\_____\/\\\__\//\\\\\\_\/\\\___________\///\\\__/\\\______/\\\/___________\//\\\____/\\\__\//\\\____/\\\__\//\\\____/\\\___/\\\______/\\\____________\/\\\_______\/\\\___/\\\/___________  
--        __/\\\\\\\\\\\_\/\\\___\//\\\\\_\/\\\_____________\///\\\\\/______/\\\\\\\\\\\\\\\__\///\\\\\\\/____\///\\\\\\\/____\///\\\\\\\/___\///\\\\\\\\\/_____________\/\\\_______\/\\\__/\\\\\\\\\\\\\\\_ 
--         _\///////////__\///_____\/////__\///________________\/////_______\///////////////_____\///////________\///////________\///////_______\/////////_______________\///________\///__\///////////////__

-- Your Name: Vanesa Reategui Gutierrez
-- Your Student Number: 1606065
-- By submitting, you declare that this work was completed entirely by yourself.

-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q1

SELECT id AS IMDBMovieID, title AS MovieTitle
FROM imdb_movie
WHERE id IS NOT NULL
	AND id NOT IN (
			  -- get all the movies that have a review in metacritic review
			  SELECT imdb_movie_id
			  FROM metacritic_review
              WHERE imdb_movie_id IS NOT NULL
);

-- END Q1
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q2

SELECT m.id AS NetflixMovieID, m.title AS MovieTitle, r.timestamp As TimeOfMostRecentRating
FROM netflix_movie m
-- join movies with their ratings using column (id from netflix_movie) and column(movie_id from netflix_rating)
INNER JOIN netflix_rating r 
	ON m.id = r.movie_id
ORDER BY r.timestamp DESC
Limit 1;

-- END Q2
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q3

SELECT movie_id AS IMDBMovieID, COUNT(user_id) AS NetflixRatingCount
FROM netflix_rating
INNER JOIN imdb_to_netflix id
	ON id.netflix_movie_id=netflix_rating.movie_id
INNER JOIN metacritic_review mr
	ON id.imdb_movie_id = mr.imdb_movie_id
WHERE source = 'The Washington Post'
GROUP BY movie_id
HAVING COUNT(user_id) >= 5;


-- END Q3
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q4

SELECT genre_title AS genre, TomatometerAvgScore
FROM (SELECT g.genre_title, ROUND(AVG(sp.critic_score), 1) AS TomatometerAvgScore
    FROM imdb_movie m
    INNER JOIN imdb_movie_genre g ON m.id = g.movie_id
    INNER JOIN imdb_to_rottentomatoes rt ON rt.imdb_movie_id = m.id
    INNER JOIN rottentomatoes_movie sp ON sp.id = rt.rt_movie_id
    GROUP BY g.genre_title
) AS GenreAverage 
WHERE TomatometerAvgScore = (SELECT MAX(TomatometerAvgScore)
							FROM (
							SELECT ROUND(AVG(sp.critic_score), 1) AS TomatometerAvgScore
							FROM imdb_movie m
                            INNER JOIN imdb_movie_genre g ON m.id = g.movie_id
							INNER JOIN imdb_to_rottentomatoes rt ON rt.imdb_movie_id = m.id
							INNER JOIN rottentomatoes_movie sp ON sp.id = rt.rt_movie_id
							GROUP BY g.genre_title) AS TempAvg
							);
        
-- END Q4
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q5

SELECT DISTINCT mr.score AS Score, mr.source AS Source, MovieNActor.MovieTitle
FROM (SELECT m.id AS MovieID,
           m.title AS MovieTitle
	  FROM imdb_movie m
      INNER JOIN imdb_acted_in ap -- join actor with its movie
		ON m.id = ap.movie_id 
	  INNER JOIN imdb_person p -- actor's id to name
		ON ap.person_id = p.id
	  WHERE p.name LIKE '% % %'-- meet condition of more than two words & remove trailing spaces
      GROUP BY m.id, m.title
) AS MovieNActor
INNER JOIN metacritic_review mr 
    ON mr.imdb_movie_id = MovieNActor.MovieID; 
    
-- END Q5
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q6
	
SELECT year.year AS Year, year.MovieCount
FROM (
    SELECT m.year, COUNT(DISTINCT m.id) AS MovieCount
    FROM imdb_movie m
    INNER JOIN movielens_tag t
        ON m.id = t.movie_id
    WHERE m.classification = 'pg'
      AND t.tag = 'action_thriller'
    GROUP BY m.year
) year
WHERE year.MovieCount = (
    SELECT MAX(sub.MovieCount)
    FROM (SELECT m.year, COUNT(DISTINCT m.id) AS MovieCount
          FROM imdb_movie m
          INNER JOIN movielens_tag t
            ON m.id = t.movie_id
          WHERE m.classification = 'pg'
            AND t.tag = 'action_thriller'
          GROUP BY m.year
    )sub
);

-- END Q6
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q7
 
SELECT(SELECT COUNT(*)
		FROM imdb_movie m
		WHERE m.id NOT IN (SELECT l.imdb_movie_id
						   FROM imdb_to_netflix l
                           WHERE l.netflix_movie_id IS NOT NULL)
)AS X,
		(SELECT COUNT(*)
		FROM imdb_movie m
		WHERE m.id NOT IN (SELECT mm.imdb_movie_id 
						   FROM imdb_to_movielens mm
						   WHERE mm.movielens_movie_id IS NOT NULL)
) AS Y;

-- END Q7
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q8

SELECT rm.source AS globalReviewSource, 
       im.language, 
       COUNT(*) AS countReviewsForLanguage,
       ROUND(AVG(rm.score), 1) AS avgScoreForLanguage,
       ROUND(STDDEV(rm.score), 1) AS popStdDevScoreForLanguage
FROM imdb_movie im
INNER JOIN metacritic_review rm
    ON im.id = rm.imdb_movie_id
WHERE rm.source IN (SELECT rm2.source
					FROM imdb_movie im2
					INNER JOIN metacritic_review rm2
						ON im2.id = rm2.imdb_movie_id
					GROUP BY rm2.source
					HAVING COUNT(DISTINCT im2.language) = (SELECT COUNT(DISTINCT language) 
														   FROM imdb_movie)
)
GROUP BY rm.source, im.language
ORDER BY rm.source, im.language;

-- END Q8
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q9

SELECT at.ActorName, 
       at.NumberOfUniqueGenres, 
       COALESCE(ta.TotalNumberOfTags, 0) AS TotalNumberOfTags -- if null put 0
FROM (SELECT
        p.id AS person_id,
        p.name AS ActorName,
        COUNT(DISTINCT g.genre_title) AS NumberOfUniqueGenres
    FROM imdb_person p
    INNER JOIN imdb_acted_in a  
        ON p.id = a.person_id
    INNER JOIN imdb_movie_genre g  
        ON a.movie_id = g.movie_id
    GROUP BY p.id, p.name
    HAVING COUNT(DISTINCT g.genre_title) >= 5 
) at
LEFT JOIN (
	SELECT a.person_id, COUNT(t.tag) AS TotalNumberOfTags
	FROM imdb_acted_in a
    INNER JOIN movielens_tag t
        ON a.movie_id = t.movie_id
    GROUP BY a.person_id
) ta
    ON at.person_id = ta.person_id;

-- END Q9
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q10

SELECT ConsistentMovies.NetflixMovieID, ConsistentMovies.RoundedAvgMetacriticScore, ConsistentMovies.RoundedAvgNetflixScoreAsPercent
FROM (SELECT nm.id AS NetflixMovieID, ROUND(ma.AvgMetacriticScore, 1) AS RoundedAvgMetacriticScore, ROUND(na.AvgNetflixPercent, 1) AS RoundedAvgNetflixScoreAsPercent-- all movies from 2021 and 2022.
      FROM netflix_movie nm
      INNER JOIN(SELECT nr.movie_id, AVG(nr.rating * 20.0) AS AvgNetflixPercent -- makes it out of 100
           FROM netflix_rating nr
           GROUP BY nr.movie_id) na
		ON nm.id = na.movie_id
      INNER JOIN imdb_to_netflix map
        ON nm.id = map.netflix_movie_id
	  INNER JOIN(SELECT mr.imdb_movie_id, AVG(mr.score) AS AvgMetacriticScore -- average Metacritic score
           FROM metacritic_review mr
           GROUP BY mr.imdb_movie_id) ma
        ON map.imdb_movie_id = ma.imdb_movie_id
      WHERE nm.year IN (2021, 2022) AND ABS(na.AvgNetflixPercent - ma.AvgMetacriticScore) <= 15 -- ensure it is within 15 bound
      ) AS ConsistentMovies
WHERE ConsistentMovies.RoundedAvgNetflixScoreAsPercent >= (SELECT MIN(sub.RoundedAvgNetflixScoreAsPercent)
														   FROM(SELECT ROUND(na2.AvgNetflixPercent, 1) AS RoundedAvgNetflixScoreAsPercent  -- find the top 3 consistent movies based on their Netflix score
														   FROM netflix_movie nm2
														   INNER JOIN (SELECT nr2.movie_id, AVG(nr2.rating * 20.0) AS AvgNetflixPercent
																  FROM netflix_rating nr2
																  GROUP BY nr2.movie_id) na2 
																ON nm2.id = na2.movie_id
															INNER JOIN imdb_to_netflix map2 
																ON nm2.id = map2.netflix_movie_id
															INNER JOIN(SELECT mr2.imdb_movie_id, AVG(mr2.score) AS AvgMetacriticScore
																 FROM metacritic_review mr2
																 GROUP BY mr2.imdb_movie_id) ma2
																ON map2.imdb_movie_id = ma2.imdb_movie_id
															WHERE nm2.year IN (2021, 2022) AND ABS(na2.AvgNetflixPercent - ma2.AvgMetacriticScore) <= 15
															GROUP BY nm2.id
															ORDER BY RoundedAvgNetflixScoreAsPercent DESC
															LIMIT 3) AS sub)
ORDER BY ConsistentMovies.RoundedAvgNetflixScoreAsPercent DESC, ConsistentMovies.NetflixMovieID;

-- END Q10
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- END OF ASSIGNMENT Do not write below this line