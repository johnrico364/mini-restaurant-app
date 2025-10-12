import { useQuery } from "@tanstack/react-query";
import axios from "axios";

// GET ALL RESERVATIONS
export const useReservations = () => {
  return useQuery({
    queryKey: ["reservations"],
    queryFn: async () => {
      const { data: reservations } = await axios.get(
        "https://my-json-server.typicode.com/johnrico364/mini-restaurant-app/reservations"
      );

      return reservations;
    },
  });
};
