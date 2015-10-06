--this file is for the database for CBR
CREATE TABLE recordhead(
                        rcode int PRIMARY KEY,--record code
                        lcode int, --locate code
                        city varchar(40), --city name
                        spot varchar(60), --spot name
                        fdate date, --first date
                        ldate date, --last date
                        ucode int, --user code
                        uname varchar(40), --user name
                        num int --bird species number
                        );
			
CREATE TABLE birdname(
                      bcode int PRIMARY KEY,
                      family varchar(30),
                      bname varchar(60)
                      );

CREATE TABLE birdlist(
                      rcode int REFERENCES recordhead(rcode),
                      bcode int REFERENCES birdname(bcode), --bird code
                      amount int, --bird amount
                      PRIMARY KEY(rcode,bcode)
                     );

CREATE TABLE birdinfo(
                      code int,
                      bcode char(5),
                      latin varchar(40),
                      chinese varchar(40),
                      english varchar(40),
                      iucn2013 char(2),
                      cites2014 char(2),
                      national1989 char(2),
                      fauna char(6),
                      corder varchar(8),
                      lorder varchar(30),
                      cfamily varchar(10),
                      lfamily varchar(30),
                      PRIMARY KEY (code, bcode)
                      );

CREATE TABLE location(
                      lcode int PRIMARY KEY,
                      city varchar(40),
                      spot varchar(60)
                     );


COPY birdname FROM './Database/birdname.csv' WITH CSV;

COPY recordhead FROM './Database/rh1utf.csv' WITH CSV;

COPY recordhead FROM './Database/rh2utf.csv' WITH CSV;

COPY recordhead FROM './Database/rh3utf.csv' WITH CSV;

COPY recordhead FROM './Database/rh4utf.csv' WITH CSV;

COPY recordhead FROM './Database/rh5utf.csv' WITH CSV;

COPY birdlist FROM './Database/birdlist1utf.csv' WITH CSV;

COPY birdlist FROM './Database/birdlist2utf.csv' WITH CSV;

COPY birdlist FROM './Database/birdlist3utf.csv' WITH CSV;

COPY birdlist FROM './Database/birdlist4utf.csv' WITH CSV;

COPY birdlist FROM './Database/birdlist5utf.csv' WITH CSV;

INSERT INTO location (SELECT DISTINCT recordhead.lcode, recordhead.city, recordhead.spot FROM recordhead);  

SELECT count(*) FROM recordhead; --find the total number of records

SELECT count(*) FROM birdlist; --find the total number of item

COPY (SELECT DISTINCT lcode, city, spot FROM recordhead ORDER BY city) TO './locate.csv' WITH CSV;

--choose the spots with most records

COPY (SELECT recordhead.city, spot, count(rcode) FROM recordhead GROUP BY city, spot ORDER BY count(rcode) DESC LIMIT 100) TO './topspot.csv' WITH CSV;  

--choose the birds with most items
COPY (SELECT birdlist.bcode, birdname.bname, count(birdlist.bcode) FROM birdlist, birdname WHERE birdlist.bcode=birdname.bcode GROUP BY birdlist.bcode, birdname.bname ORDER BY count(birdlist.bcode) DESC LIMIT 100) TO './topbird.csv';

COPY (SELECT birdlist.bcode, birdname.bname, avg(birdlist.amount) FROM birdlist, birdname WHERE birdlist.bcode=birdname.bcode GROUP BY birdlist.bcode, birdname.bname ORDER BY count(birdlist.bcode) DESC LIMIT 100) TO './topbirdper.csv';

COPY (SELECT DISTINCT birdlist.bcode, birdname.bname, birdname.family, recordhead.city, recordhead.spot FROM birdname, recordhead, birdlist WHERE birdlist.bcode=birdname.bcode AND birdlist.rcode=recordhead.rcode AND recordhead.spot='弄岗保护区' ORDER BY birdlist.bcode) TO './弄岗保护区.csv' WITH CSV;

COPY (SELECT DISTINCT birdlist.bcode, birdname.bname, birdname.family, recordhead.city, recordhead.spot FROM birdname, recordhead, birdlist WHERE birdlist.bcode=birdname.bcode AND birdlist.rcode=recordhead.rcode AND recordhead.spot='弄岗保护区陇瑞站' ORDER BY birdlist.bcode) TO './弄岗保护区陇瑞站.csv' WITH CSV;
