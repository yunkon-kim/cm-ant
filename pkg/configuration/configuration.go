package configuration

import (
	"fmt"
	"log"
	"os"
	"strings"
	"sync"
	"time"

	"github.com/cloud-barista/cm-ant/pkg/load/domain/model"
	"github.com/joho/godotenv"
	"github.com/spf13/viper"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

var (
	appConfig *AntConfig
	once      sync.Once
	db        *gorm.DB
)

func Get() *AntConfig {
	if appConfig == nil {
		log.Println(">>>> configuration process has not completed")

		once.Do(func() {
			err := Initialize()
			if err != nil {
				log.Fatal(">>>> configuration failure")
			}
		})
	}

	return appConfig
}

func DB() *gorm.DB {
	if db == nil {
		log.Fatal("database is not configured")
	}
	return db
}

type AntConfig struct {
	Spider struct {
		Host string `yaml:"host"`
		Port string `yaml:"port"`
	} `yaml:"spider"`
	Tumblebug struct {
		Host     string `yaml:"host"`
		Port     string `yaml:"port"`
		Username string `yaml:"username"`
		Password string `yaml:"password"`
	} `yaml:"tumblebug"`
	Load struct {
		JMeter struct {
			WorkDir string `yaml:"workDir"`
			Version string `yaml:"version"`
		} `yaml:"jmeter"`
	} `yaml:"load"`
	Server struct {
		Port string `yaml:"port"`
	} `yaml:"server"`
	Datasource struct {
		Driver     string `yaml:"driver"`
		Connection string `yaml:"connection"`
		Username   string `yaml:"username"`
		Password   string `yaml:"password"`
	} `yaml:"datasource"`
}

func Initialize() error {

	log.Println(">>>> start initialize application configuration")

	// configure app
	err := initAppConfig()
	if err != nil {
		log.Fatal(err)
		return err
	}

	// config database
	err = initDatabase()
	if err != nil {
		log.Fatal(err)
		return err
	}

	log.Println(">>>> complete initialize application configuration")

	return nil
}

func initAppConfig() error {
	log.Println(">>>> start initAppConfig()")

	err := godotenv.Load()
	if err != nil {
		log.Fatal("Error loading .env file")
	}

	cfg := AntConfig{}

	viper.AddConfigPath(RootPath())
	viper.SetConfigName("config")
	viper.SetConfigType("yaml")

	err = viper.ReadInConfig()
	if err != nil {
		return fmt.Errorf("fatal error config file: %w", err)
	}

	viper.SetEnvKeyReplacer(strings.NewReplacer(".", "_"))
	viper.AutomaticEnv()

	err = viper.Unmarshal(&cfg)
	if err != nil {
		return fmt.Errorf("fatal error config file: %w", err)
	}
	appConfig = &cfg
	log.Println(">>>> completed initAppConfig()")

	return nil
}

func initDatabase() error {
	log.Println(">>>> start initDatabase()")
	ds := Get().Datasource

	if ds.Driver == "sqlite" || ds.Driver == "sqlite3" {
		sqlFilePath := sqliteFilePath()
		sqliteDB, err := connectSqliteDB(sqlFilePath)
		if err != nil {
			log.Fatal(err)
		}

		err = migrateDB(sqliteDB)
		if err != nil {
			log.Fatal(err)
		}

		db = sqliteDB
	}
	log.Println(">>>> complete initDatabase()")
	return nil
}
func migrateDB(defaultDb *gorm.DB) error {
	err := defaultDb.AutoMigrate(
		&model.LoadEnv{},
		&model.LoadExecutionConfig{},
		&model.LoadExecutionState{},
		&model.LoadExecutionHttp{},
		&model.AgentInstallInfo{},
	)

	if err != nil {
		log.Println("connectSqliteDB() fail to connect to sqlite database")
		return err
	}

	return nil
}

func connectSqliteDB(dbPath string) (*gorm.DB, error) {
	log.Println(">>>> sqlite configuration; meta sqliteDb path is", dbPath)

	newLogger := logger.New(
		log.New(os.Stdout, "\r", log.LstdFlags),
		logger.Config{
			SlowThreshold: time.Second,
			// LogLevel:                  logger.Info,
			IgnoreRecordNotFoundError: true,
			ParameterizedQueries:      true,
			Colorful:                  true,
		},
	)

	sqliteDb, err := gorm.Open(sqlite.Open(dbPath), &gorm.Config{
		Logger: newLogger,
	})
	if err != nil {
		log.Println("connectSqliteDB() fail to connect to sqlite database")
		return nil, err
	}

	return sqliteDb, nil
}

func sqliteFilePath() string {
	dbFile := Get().Datasource.Connection
	rp := RootPath()

	if dbFile != "" {
		dbFile = strings.Replace(dbFile, "${ROOT}", rp, 1)
	} else {
		dbFile = rp + "/meta/ant_meta.db"
	}
	return dbFile
}