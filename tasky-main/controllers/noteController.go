package controller

import (
	"context"
	"log"
	"net/http"
	"time"

	"github.com/jeffthorne/tasky/database"
	"github.com/jeffthorne/tasky/models"

	"github.com/gin-gonic/gin"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
)

var noteCollection *mongo.Collection = database.OpenCollection(database.Client, "notes")

func CreateNote(c *gin.Context) {
	var note models.Note
	if err := c.BindJSON(&note); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	note.ID = primitive.NewObjectID()
	// Vulnerability: UserID is taken from request, not session
	log.Printf("[VULN] Creating note for user_id: %s, title: %s, body: %s", note.UserID, note.Title, note.Body)

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	_, err := noteCollection.InsertOne(ctx, note)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"insertedId": note.ID})
}

func GetNote(c *gin.Context) {
	id := c.Param("id")
	objId, _ := primitive.ObjectIDFromHex(id)
	var note models.Note
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	err := noteCollection.FindOne(ctx, bson.M{"_id": objId}).Decode(&note)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Note not found"})
		return
	}
	// Vulnerability: No user check
	log.Printf("[VULN] Retrieved note: %+v", note)
	c.JSON(http.StatusOK, note)
}

func UpdateNote(c *gin.Context) {
	id := c.Param("id")
	objId, _ := primitive.ObjectIDFromHex(id)
	var updateData models.Note
	if err := c.BindJSON(&updateData); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	update := bson.M{
		"$set": bson.M{
			"title": updateData.Title,
			"body":  updateData.Body,
			"tags":  updateData.Tags,
		},
	}
	// Vulnerability: No user check
	log.Printf("[VULN] Updating note %s to %+v", id, updateData)
	_, err := noteCollection.UpdateOne(ctx, bson.M{"_id": objId}, update)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"updatedId": id})
}

func DeleteNote(c *gin.Context) {
	id := c.Param("id")
	objId, _ := primitive.ObjectIDFromHex(id)
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	// Vulnerability: No user check
	log.Printf("[VULN] Deleting note %s", id)
	_, err := noteCollection.DeleteOne(ctx, bson.M{"_id": objId})
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"deletedId": id})
}

func ListNotes(c *gin.Context) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	cursor, err := noteCollection.Find(ctx, bson.M{})
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	var notes []models.Note
	for cursor.Next(ctx) {
		var note models.Note
		if err := cursor.Decode(&note); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		notes = append(notes, note)
	}
	// Vulnerability: Returns all notes, no user filtering
	log.Printf("[VULN] Listing all notes, count: %d", len(notes))
	c.JSON(http.StatusOK, notes)
} 