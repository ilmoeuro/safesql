CREATE TABLE "Employee" (
    "id" INTEGER NOT NULL AUTO_INCREMENT,
    "name" VARCHAR(255) NOT NULL,
    "age" INTEGER NOT NULL,
    "salary" DOUBLE NOT NULL,
    "company" INTEGER NOT NULL,
    PRIMARY KEY ("id")
);

INSERT INTO "Employee" (
    "name",
    "age",
    "salary",
    "company"
) VALUES (
    'Harry',
    37,
    50000.0,
    0
)