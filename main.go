package main

import (
	"context"
	"log"
	"net/http"
	"os"

	"github.com/Mor1oc/backend-managing-requirements/internal/database"
	"github.com/Mor1oc/backend-managing-requirements/internal/handlers"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/joho/godotenv"
	"github.com/labstack/echo/v5"
	"github.com/labstack/echo/v5/middleware"
	_ "github.com/lib/pq"
)

func main() {
	godotenv.Load(".env")

	portString := os.Getenv("PORT")
	if portString == "" {
		log.Fatal("PORT is not found in .env file")
	}

	dbURL := os.Getenv("DB_URL")
	if dbURL == "" {
		log.Fatal("DB_URL is not found in .env file")
	}

	pool, err := pgxpool.New(context.Background(), dbURL)
	if err != nil {
		log.Fatal("Unable to connect to database:", err)
	}
	defer pool.Close()
	queries := database.New(pool)
	apiCfg := handlers.ApiConfig{
		DB:   queries,
		Pool: pool,
	}

	e := echo.New()
	e.Use(middleware.RequestLogger())
	e.Use(middleware.Recover())

	e.Use(middleware.CORSWithConfig(middleware.CORSConfig{
		AllowOrigins: []string{
			"*",
			// "http://localhost:3000",
		},
		AllowMethods:  []string{http.MethodGet, http.MethodPost, http.MethodPut, http.MethodDelete, http.MethodOptions},
		AllowHeaders:  []string{echo.HeaderOrigin, echo.HeaderContentType, echo.HeaderAccept, echo.HeaderAuthorization},
		ExposeHeaders: []string{"Link", "X-Total-Count"},
		MaxAge:        3600,
	}))

	userGroup := e.Group("/user")
	// добавить auth
	userGroup.POST("/", apiCfg.HandlerCreateUser)
	userGroup.PUT("/", apiCfg.HandlerUpdateUser)

	requirementGroup := e.Group("/requrement")
	requirementGroup.GET("/all", apiCfg.HandlerGetAllRequirements)
	requirementGroup.GET("/:id/versions", apiCfg.HandlerGetAllRequirementVersions)

	aprovalGroup := e.Group("/aproval")
	aprovalGroup.GET("/all", apiCfg.HandlerGetAllAprovals)
	aprovalGroup.POST("/:requirement_id", apiCfg.HandlerCreateAproval)
	aprovalGroup.PUT("/:requirement_id", apiCfg.HandlerUpdateAproval)

	projectGroup := e.Group("/project")
	projectGroup.GET("/all", apiCfg.HandlerGetAllProjects)
	projectGroup.POST("/create", apiCfg.HandlerCreateProject)
	projectGroup.PUT("/update", apiCfg.HandlerUpdateProject)
	projectGroup.GET("/:project_id/requirements", apiCfg.HandlerGetRequirementsByProjectId)
	projectGroup.GET("/:project_id", apiCfg.HandlerGetAllAprovalsByProjectId)

	documentGroup := e.Group("/document")
	documentGroup.GET("/all", apiCfg.HandlerGetAllDocuments)
	documentGroup.GET("/:id", apiCfg.HandlerGetDocumentById)

	ecrGroup := e.Group("/ecr")
	ecrGroup.GET("/all", apiCfg.HandlerGetAllEcr)
	ecrGroup.POST("/", apiCfg.HandleCreateECRequest)
	ecrGroup.POST("/eco", apiCfg.HandleCreateECOrder)
	ecrGroup.PATCH("/:id", apiCfg.HandlerUpdateStatusEcr)

	ecoGroup := e.Group("/eco")
	ecoGroup.GET("/all", apiCfg.HandlerGetAllEco)
	ecoGroup.GET("/:id", apiCfg.HandlerGetEcoById)
	ecoGroup.PATCH("/:id", apiCfg.HandlerUpdateStatusEco)

	log.Printf("Server is starting on port %v", portString)
	err = e.Start(":" + portString)
	if err != nil {
		log.Fatal(err)
	}
}
