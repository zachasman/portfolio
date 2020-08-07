--Use in tandem with the R scraper. Purpose is to recreate 247sports.com's recruiting class calculator.

SELECT school,
       COUNT(prospect) class_size,
       AVG(rating) avg_rating,
       MAX(total) composite_score
FROM
  (SELECT prospect,
          school,
          rating,
          ranked,
          value,
          ROUND((((rating*100)-70)*value)::numeric,2) composite,
          SUM(ROUND((((rating*100)-70)*value)::numeric,2)) OVER (PARTITION BY school
                                                               ORDER BY rating DESC) total
   FROM
     (SELECT prospect,
             rating,
             school,
             ROW_NUMBER() OVER (PARTITION BY school
                                ORDER BY rating DESC) ranked
      FROM zasman213.proj_2021_v2) osu
   JOIN zasman213.index ind
     ON osu.ranked = ind.index) done
WHERE school <> ''
GROUP BY 1
ORDER BY 4 DESC

